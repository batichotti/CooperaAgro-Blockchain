import { ethers } from "ethers";
import { createServer } from "http";
import type { IncomingMessage, ServerResponse } from "http";
import { readFileSync } from "fs";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";
import { config as dotenvConfig } from "dotenv";

// __dirname equivalente em ESM — resolve a partir do arquivo, não do CWD
const __filename = fileURLToPath(import.meta.url);
const __dirname  = dirname(__filename);

// .env está em backend/ na raiz do projeto
dotenvConfig({ path: resolve(__dirname, "../../../../backend/.env") });

const SEPOLIA_URL   = process.env["SEPOLIA_URL"]  ?? "";
const PRIVATE_KEY   = process.env["PRIVATE_KEY"]  ?? "";
const CONTRACT_ADDR = "0xB38D419eDBd6917cE3d3e7990a99233E9Dbf1336";
const PORT          = 3000;

if (!SEPOLIA_URL || !PRIVATE_KEY) {
  process.stderr.write("❌ SEPOLIA_URL ou PRIVATE_KEY ausentes no .env\n");
  process.stderr.write("   Caminho buscado: " + resolve(__dirname, "../../../../backend/.env") + "\n");
  process.exit(1);
}

// ─── ABI ─────────────────────────────────────────────────────────────────────
const ABI = [
  "function root() view returns (uint256)",
  "function memoryPool(uint256 id) view returns (uint256 left, uint256 right, int256 key, uint8 color)",
  "function insert(int256 _key, tuple(uint256 id, bytes32 hash)[] _metrics, tuple(uint256 id, bytes32 hash)[] _evidences)",
  "function getMetrics(int256 _key) view returns (tuple(uint256 id, bytes32 hash)[])",
  "function getEvidences(int256 _key) view returns (tuple(uint256 id, bytes32 hash)[])",
];

// ─── TIPOS ───────────────────────────────────────────────────────────────────
interface Tuple    { id: bigint; hash: string }
interface TreeNode {
  id:    string;
  key:   string;
  color: "RED" | "BLACK";
  left:  TreeNode | null;
  right: TreeNode | null;
}
type InsertBody = {
  key:       string;
  metrics:   Array<{ id: string; hash: string }>;
  evidences: Array<{ id: string; hash: string }>;
};

// ─── BLOCKCHAIN ───────────────────────────────────────────────────────────────
const provider = new ethers.JsonRpcProvider(SEPOLIA_URL);
const wallet   = new ethers.Wallet(PRIVATE_KEY, provider);
const base     = new ethers.Contract(CONTRACT_ADDR, ABI, wallet);

const contract = {
  root:         ()           => base["root"]()         as Promise<bigint>,
  memoryPool:   (id: bigint) => base["memoryPool"](id) as Promise<{ left: bigint; right: bigint; key: bigint; color: bigint }>,
  insert:       (k: bigint, m: Tuple[], e: Tuple[]) =>
                               base["insert"](k, m, e) as Promise<ethers.ContractTransactionResponse>,
  getMetrics:   (k: bigint) => base["getMetrics"](k)   as Promise<ReadonlyArray<{ id: bigint; hash: string }>>,
  getEvidences: (k: bigint) => base["getEvidences"](k) as Promise<ReadonlyArray<{ id: bigint; hash: string }>>,
};

function ensureBytes32(value: string): `0x${string}` {
  if (/^0x[0-9a-fA-F]{64}$/.test(value)) return value as `0x${string}`;
  return ethers.keccak256(ethers.toUtf8Bytes(value)) as `0x${string}`;
}

async function buildTree(id: bigint, depth = 0): Promise<TreeNode | null> {
  if (id === 0n || depth > 60) return null;
  const n = await contract.memoryPool(id);
  return {
    id:    id.toString(),
    key:   n.key.toString(),
    color: n.color === 0n ? "RED" : "BLACK",
    left:  await buildTree(n.left,  depth + 1),
    right: await buildTree(n.right, depth + 1),
  };
}

// ─── HTTP UTILS ───────────────────────────────────────────────────────────────
function readBody(req: IncomingMessage): Promise<string> {
  return new Promise((ok, fail) => {
    let data = "";
    req.on("data",  (c: Buffer) => { data += c.toString(); });
    req.on("end",   () => ok(data));
    req.on("error", fail);
  });
}

function sendJson(res: ServerResponse, status: number, body: unknown): void {
  const text = JSON.stringify(body);
  res.writeHead(status, {
    "Content-Type":                "application/json; charset=utf-8",
    "Content-Length":              Buffer.byteLength(text).toString(),
    "Access-Control-Allow-Origin": "*",
  });
  res.end(text);
}

// ─── SERVIDOR ────────────────────────────────────────────────────────────────
const HTML_PATH = resolve(__dirname, "../public/rbt.html");

createServer(async (req: IncomingMessage, res: ServerResponse) => {
  const url    = new URL(req.url ?? "/", `http://localhost:${PORT}`);
  const method = req.method ?? "GET";

  try {
    if (url.pathname === "/" && method === "GET") {
      const html = readFileSync(HTML_PATH, "utf8");
      res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
      res.end(html);
      return;
    }

    if (url.pathname === "/api/status" && method === "GET") {
      const [balance, network] = await Promise.all([
        provider.getBalance(wallet.address),
        provider.getNetwork(),
      ]);
      sendJson(res, 200, {
        wallet:   wallet.address,
        balance:  ethers.formatEther(balance),
        network:  network.name,
        contract: CONTRACT_ADDR,
      });
      return;
    }

    if (url.pathname === "/api/tree" && method === "GET") {
      const rootId = await contract.root();
      const tree   = await buildTree(rootId);
      sendJson(res, 200, { root: tree });
      return;
    }

    if (url.pathname === "/api/insert" && method === "POST") {
      const raw       = JSON.parse(await readBody(req)) as InsertBody;
      const metrics   = raw.metrics.map(m   => ({ id: BigInt(m.id), hash: ensureBytes32(m.hash) }));
      const evidences = raw.evidences.map(e => ({ id: BigInt(e.id), hash: ensureBytes32(e.hash) }));
      const tx        = await contract.insert(BigInt(raw.key), metrics, evidences);
      const receipt   = await tx.wait();
      sendJson(res, 200, { hash: tx.hash, blockNumber: receipt?.blockNumber ?? null });
      return;
    }

    if (url.pathname === "/api/metrics" && method === "GET") {
      const key    = url.searchParams.get("key") ?? "0";
      const result = await contract.getMetrics(BigInt(key));
      sendJson(res, 200, Array.from(result).map(m => ({ id: m.id.toString(), hash: m.hash })));
      return;
    }

    if (url.pathname === "/api/evidences" && method === "GET") {
      const key    = url.searchParams.get("key") ?? "0";
      const result = await contract.getEvidences(BigInt(key));
      sendJson(res, 200, Array.from(result).map(e => ({ id: e.id.toString(), hash: e.hash })));
      return;
    }

    res.writeHead(404); res.end("Not Found");

  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    sendJson(res, 500, { error: msg });
  }
}).listen(PORT, () => {
  console.log("\n🌳 Red-Black Tree — Sepolia Testnet");
  console.log("Contrato : " + CONTRACT_ADDR);
  console.log("Wallet   : " + wallet.address);
  console.log("Acesse   : http://localhost:" + PORT + "\n");
});

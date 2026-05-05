import { ethers } from "ethers";
import { createServer } from "http";
import type { IncomingMessage, ServerResponse } from "http";
import { resolve } from "path";
import { config as dotenvConfig } from "dotenv";

dotenvConfig({ path: resolve("../.env") });

const SEPOLIA_URL    = process.env["SEPOLIA_URL"]  ?? "";
const PRIVATE_KEY    = process.env["PRIVATE_KEY"]  ?? "";
const CONTRACT_ADDR  = "0xB38D419eDBd6917cE3d3e7990a99233E9Dbf1336";
const PORT           = 3000;

if (!SEPOLIA_URL || !PRIVATE_KEY) {
  process.stderr.write("❌ SEPOLIA_URL ou PRIVATE_KEY ausentes no .env\n");
  process.exit(1);
}

// ─── ABI ────────────────────────────────────────────────────────────────────
const ABI = [
  "function root() view returns (uint256)",
  "function memoryPool(uint256 id) view returns (uint256 left, uint256 right, int256 key, uint8 color)",
  "function insert(int256 _key, tuple(uint256 id, bytes32 hash)[] _metrics, tuple(uint256 id, bytes32 hash)[] _evidences)",
  "function getMetrics(int256 _key) view returns (tuple(uint256 id, bytes32 hash)[])",
  "function getEvidences(int256 _key) view returns (tuple(uint256 id, bytes32 hash)[])",
  "function hash(string _value) pure returns (bytes32)",
];

// ─── TYPES ───────────────────────────────────────────────────────────────────
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

// ─── BLOCKCHAIN SETUP ────────────────────────────────────────────────────────
const provider = new ethers.JsonRpcProvider(SEPOLIA_URL);
const wallet   = new ethers.Wallet(PRIVATE_KEY, provider);
const base     = new ethers.Contract(CONTRACT_ADDR, ABI, wallet);

const contract = {
  root:         ()              => base["root"]()           as Promise<bigint>,
  memoryPool:   (id: bigint)    => base["memoryPool"](id)   as Promise<{ left: bigint; right: bigint; key: bigint; color: bigint }>,
  insert:       (k: bigint, m: Tuple[], e: Tuple[]) =>
                                   base["insert"](k, m, e)  as Promise<ethers.ContractTransactionResponse>,
  getMetrics:   (k: bigint)    => base["getMetrics"](k)    as Promise<ReadonlyArray<{ id: bigint; hash: string }>>,
  getEvidences: (k: bigint)    => base["getEvidences"](k)  as Promise<ReadonlyArray<{ id: bigint; hash: string }>>,
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

// ─── HTTP UTILS ──────────────────────────────────────────────────────────────
function readBody(req: IncomingMessage): Promise<string> {
  return new Promise((res, rej) => {
    let data = "";
    req.on("data",  (c: Buffer) => { data += c.toString(); });
    req.on("end",   () => res(data));
    req.on("error", rej);
  });
}

function sendJson(res: ServerResponse, status: number, body: unknown): void {
  const text = JSON.stringify(body);
  res.writeHead(status, {
    "Content-Type":   "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(text).toString(),
  });
  res.end(text);
}

// ─── HTML ────────────────────────────────────────────────────────────────────
const HTML = `<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Arvore Rubro-Negra — Blockchain</title>
<style>
:root {
  --bg:#0f1117; --surface:#1a1f2e; --surface2:#242940;
  --border:#2d3748; --text:#e2e8f0; --muted:#718096;
  --accent:#4299e1; --success:#48bb78; --error:#fc8181;
  --red-fill:#9b2335; --red-border:#e53e3e;
  --blk-fill:#1e2535; --blk-border:#4a5568;
}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:var(--bg);color:var(--text);height:100vh;display:flex;flex-direction:column;overflow:hidden}
header{background:var(--surface);border-bottom:1px solid var(--border);padding:10px 20px;display:flex;align-items:center;gap:12px;flex-shrink:0}
header h1{font-size:.95rem;font-weight:700;white-space:nowrap}
.hinfo{display:flex;gap:12px;margin-left:auto;align-items:center;font-size:.78rem;color:var(--muted);flex-wrap:wrap}
.badge{background:var(--surface2);border:1px solid var(--border);padding:3px 8px;border-radius:4px;font-family:monospace;font-size:.72rem}
.badge.ok{border-color:var(--success);color:var(--success)}
.badge.err{border-color:var(--error);color:var(--error)}
main{display:grid;grid-template-columns:270px 1fr 270px;flex:1;overflow:hidden}
.panel{background:var(--surface);display:flex;flex-direction:column;overflow:hidden;border-right:1px solid var(--border)}
.panel:last-child{border-right:none;border-left:1px solid var(--border)}
.ph{padding:10px 14px;font-size:.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:var(--muted);border-bottom:1px solid var(--border);flex-shrink:0}
.pb{padding:14px;overflow-y:auto;flex:1}
#tree-panel{background:#0a0d14;overflow:auto;display:flex;align-items:flex-start;justify-content:center;padding:20px}
label{display:block;font-size:.72rem;color:var(--muted);margin-bottom:3px;margin-top:11px}
label:first-of-type{margin-top:0}
input[type=text],input[type=number]{width:100%;background:var(--surface2);border:1px solid var(--border);border-radius:4px;color:var(--text);padding:6px 9px;font-size:.82rem;font-family:monospace}
input:focus{outline:none;border-color:var(--accent)}
.sec{margin-top:14px}
.sec-title{font-size:.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);margin-bottom:6px}
.ti{background:var(--surface2);border:1px solid var(--border);border-radius:4px;padding:8px;margin-bottom:5px;position:relative}
.ti input{background:var(--bg);margin-bottom:4px}
.ti input:last-child{margin-bottom:0}
.rm{position:absolute;top:4px;right:5px;background:none;border:none;color:var(--muted);cursor:pointer;font-size:.9rem;padding:1px 4px;line-height:1}
.rm:hover{color:var(--error)}
.btn{display:inline-flex;align-items:center;justify-content:center;gap:5px;padding:6px 12px;border:none;border-radius:4px;font-size:.8rem;font-weight:500;cursor:pointer;transition:opacity .15s}
.btn:hover{opacity:.85} .btn:disabled{opacity:.4;cursor:not-allowed}
.btn-primary{background:var(--accent);color:#fff;width:100%;padding:9px;margin-top:14px}
.btn-ghost{background:var(--surface2);color:var(--muted);border:1px solid var(--border);width:100%;font-size:.74rem;padding:5px 10px;margin-top:5px}
.btn-icon{background:var(--surface2);color:var(--muted);border:1px solid var(--border);padding:5px 10px;font-size:.85rem}
.nkey{font-size:1.35rem;font-weight:700;margin-bottom:5px}
.cbadge{display:inline-block;padding:2px 8px;border-radius:12px;font-size:.66rem;font-weight:700;text-transform:uppercase;letter-spacing:.05em}
.cbadge.RED{background:#5c1a1a;color:#fc8181;border:1px solid var(--red-border)}
.cbadge.BLACK{background:#1a202c;color:#a0aec0;border:1px solid var(--blk-border)}
.dsec{margin-top:14px}
.dsec-title{font-size:.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);margin-bottom:6px;padding-bottom:4px;border-bottom:1px solid var(--border)}
.di{background:var(--surface2);border:1px solid var(--border);border-radius:4px;padding:7px 9px;margin-bottom:5px;font-size:.75rem}
.di .did{color:var(--muted);font-size:.68rem}
.di .dhash{font-family:monospace;color:var(--accent);word-break:break-all;font-size:.69rem;margin-top:2px}
.empty{color:var(--muted);font-size:.78rem;font-style:italic;text-align:center;padding:16px 0}
#log{background:var(--surface);border-top:1px solid var(--border);padding:7px 20px;font-size:.75rem;color:var(--muted);flex-shrink:0;min-height:34px;display:flex;align-items:center;gap:7px}
#log a{color:var(--accent);text-decoration:none}
#log a:hover{text-decoration:underline}
.spin{display:inline-block;width:11px;height:11px;border:2px solid var(--border);border-top-color:var(--accent);border-radius:50%;animation:spin .7s linear infinite;flex-shrink:0}
@keyframes spin{to{transform:rotate(360deg)}}
.tree-node{cursor:pointer}
::-webkit-scrollbar{width:5px;height:5px}
::-webkit-scrollbar-track{background:var(--bg)}
::-webkit-scrollbar-thumb{background:var(--border);border-radius:3px}
</style>
</head>
<body>

<header>
  <h1>&#127795; Arvore Rubro-Negra &mdash; Blockchain</h1>
  <div class="hinfo">
    <span>Rede: <span id="h-net" class="badge">...</span></span>
    <span>Wallet: <span id="h-wal" class="badge">...</span></span>
    <span>Saldo: <span id="h-bal" class="badge">...</span></span>
    <span id="h-st" class="badge ok">&#9679; Conectado</span>
    <button class="btn btn-icon" onclick="reloadTree()" title="Recarregar arvore">&#8635;</button>
  </div>
</header>

<main>
  <!-- INSERIR -->
  <div class="panel">
    <div class="ph">&#128221; Inserir No</div>
    <div class="pb">
      <label>Chave (int256)</label>
      <input type="number" id="inp-key" placeholder="Ex: 42" step="1">

      <div class="sec">
        <div class="sec-title">Metrics</div>
        <div id="met-list"></div>
        <button class="btn btn-ghost" onclick="addMetric()">+ Adicionar Metric</button>
      </div>

      <div class="sec">
        <div class="sec-title">Evidences</div>
        <div id="evd-list"></div>
        <button class="btn btn-ghost" onclick="addEvidence()">+ Adicionar Evidence</button>
      </div>

      <div style="font-size:.67rem;color:var(--muted);margin-top:10px;line-height:1.5">
        Hash: use <code style="color:var(--accent)">0x...(64 hex)</code> ou texto livre (sera convertido automaticamente).
      </div>

      <button class="btn btn-primary" id="btn-ins" onclick="doInsert()">
        &#9654; Inserir na Blockchain
      </button>
    </div>
  </div>

  <!-- ARVORE SVG -->
  <div id="tree-panel">
    <svg id="tree-svg" xmlns="http://www.w3.org/2000/svg"></svg>
  </div>

  <!-- DETALHES -->
  <div class="panel">
    <div class="ph">&#128202; Detalhes do No</div>
    <div class="pb" id="det-body">
      <div class="empty">Clique em um no para ver seus dados</div>
    </div>
  </div>
</main>

<div id="log"><span id="log-txt">Carregando...</span></div>

<script>
var currentRoot = null;
var selectedKey = null;
var mc = 0, ec = 0;

window.addEventListener('load', function() {
  loadStatus();
  reloadTree();
});

function loadStatus() {
  fetch('/api/status').then(function(r){ return r.json(); }).then(function(d) {
    document.getElementById('h-net').textContent = d.network || 'sepolia';
    document.getElementById('h-wal').textContent = d.wallet.slice(0,6) + '...' + d.wallet.slice(-4);
    document.getElementById('h-bal').textContent = parseFloat(d.balance).toFixed(4) + ' ETH';
  }).catch(function(e) {
    var s = document.getElementById('h-st');
    s.textContent = '● Erro'; s.className = 'badge err';
    setLog('Erro ao conectar: ' + e.message, true);
  });
}

function reloadTree() {
  setLog('<span class="spin"></span> Carregando arvore da blockchain...');
  fetch('/api/tree').then(function(r){ return r.json(); }).then(function(d) {
    currentRoot = d.root;
    renderTree(currentRoot);
    setLog(currentRoot ? '&#10003; Arvore carregada' : '&#9675; Arvore vazia &mdash; insira o primeiro no');
  }).catch(function(e) {
    setLog('Erro ao carregar: ' + e.message, true);
  });
}

// ── SVG RENDERING ────────────────────────────────────────────────────────────
function renderTree(root) {
  var svg = document.getElementById('tree-svg');
  svg.innerHTML = '';

  if (!root) {
    var panel = document.getElementById('tree-panel');
    var w = panel.clientWidth || 600, h = panel.clientHeight || 400;
    svg.setAttribute('width', w); svg.setAttribute('height', h);
    svg.setAttribute('viewBox', '0 0 ' + w + ' ' + h);
    var t = mkSvg('text', {x:w/2, y:h/2, 'text-anchor':'middle', fill:'#3d4a5c', 'font-size':'15', 'font-family':'system-ui'});
    t.textContent = 'Arvore vazia — insira o primeiro no';
    svg.appendChild(t);
    return;
  }

  // Assign in-order X positions and depth-based Y
  var xi = 0;
  function assignPos(n, d) {
    if (!n) return;
    assignPos(n.left, d+1);
    n._x = xi++; n._y = d;
    assignPos(n.right, d+1);
  }
  assignPos(root, 0);

  var total = xi;
  var depth = treeDepth(root);
  var R     = 26;
  var hGap  = Math.max(60, Math.min(90, 750 / Math.max(total,1)));
  var vGap  = 82;
  var padX  = 50, padY = 50;

  var svgW = Math.max(padX*2 + (total-1)*hGap, 400);
  var svgH = Math.max(padY*2 + (depth-1)*vGap, 160);
  svg.setAttribute('width', svgW); svg.setAttribute('height', svgH);
  svg.setAttribute('viewBox', '0 0 ' + svgW + ' ' + svgH);

  function px(n){ return padX + n._x * hGap; }
  function py(n){ return padY + n._y * vGap; }

  // Edges first
  function drawEdges(n) {
    if (!n) return;
    [n.left, n.right].forEach(function(c) {
      if (!c) return;
      var line = mkSvg('line', {x1:px(n),y1:py(n),x2:px(c),y2:py(c),stroke:'#2a3347','stroke-width':'2'});
      svg.appendChild(line);
    });
    drawEdges(n.left); drawEdges(n.right);
  }
  drawEdges(root);

  // Nodes on top
  function drawNode(n) {
    if (!n) return;
    var sel  = selectedKey === n.key;
    var isRed = n.color === 'RED';
    var g = mkSvg('g', {class:'tree-node'});
    g.addEventListener('click', function(){ selectNode(n.key, n.color); });

    if (sel) {
      svg.appendChild(mkSvg('circle', {
        cx:px(n),cy:py(n),r:R+6,fill:'none',stroke:'#ffd700','stroke-width':'2',opacity:'.5'
      }));
    }
    g.appendChild(mkSvg('circle', {
      cx:px(n),cy:py(n),r:R,
      fill: isRed ? 'var(--red-fill)' : 'var(--blk-fill)',
      stroke: isRed ? 'var(--red-border)' : (sel ? '#ffd700' : 'var(--blk-border)'),
      'stroke-width': sel ? '2.5' : '1.5'
    }));

    var key  = n.key;
    var fsize = key.length > 6 ? '9' : key.length > 4 ? '11' : '13';
    var txt = mkSvg('text', {
      x:px(n), y:py(n)+5, 'text-anchor':'middle',
      fill:'#e2e8f0','font-size':fsize,'font-weight':'bold',
      'font-family':'monospace','pointer-events':'none'
    });
    txt.textContent = key;
    g.appendChild(txt);
    svg.appendChild(g);

    drawNode(n.left); drawNode(n.right);
  }
  drawNode(root);
}

function mkSvg(tag, attrs) {
  var el = document.createElementNS('http://www.w3.org/2000/svg', tag);
  Object.keys(attrs).forEach(function(k){ el.setAttribute(k, attrs[k]); });
  return el;
}

function treeDepth(n) {
  if (!n) return 0;
  return 1 + Math.max(treeDepth(n.left), treeDepth(n.right));
}

// ── NODE SELECTION ────────────────────────────────────────────────────────────
function selectNode(key, color) {
  selectedKey = key;
  renderTree(currentRoot);

  var body = document.getElementById('det-body');
  body.innerHTML = '<div class="nkey">' + key + '</div><span class="cbadge ' + color + '">' + color + '</span><br><span class="spin" style="margin-top:10px"></span>';

  Promise.all([
    fetch('/api/metrics?key=' + key).then(function(r){ return r.json(); }),
    fetch('/api/evidences?key=' + key).then(function(r){ return r.json(); })
  ]).then(function(results) {
    var metrics   = results[0];
    var evidences = results[1];
    renderDetails(key, color, metrics, evidences);
  }).catch(function(e) {
    body.innerHTML = '<div class="empty">Erro: ' + e.message + '</div>';
  });
}

function renderDetails(key, color, metrics, evidences) {
  var mHtml = metrics.length === 0
    ? '<div class="empty">Sem metricas</div>'
    : metrics.map(function(m) {
        return '<div class="di"><div class="did">ID: ' + m.id + '</div><div class="dhash">' + m.hash + '</div></div>';
      }).join('');

  var eHtml = evidences.length === 0
    ? '<div class="empty">Sem evidencias</div>'
    : evidences.map(function(e) {
        return '<div class="di"><div class="did">ID: ' + e.id + '</div><div class="dhash">' + e.hash + '</div></div>';
      }).join('');

  document.getElementById('det-body').innerHTML =
    '<div class="nkey">' + key + '</div>' +
    '<span class="cbadge ' + color + '">' + color + '</span>' +
    '<div class="dsec"><div class="dsec-title">Metrics (' + metrics.length + ')</div>' + mHtml + '</div>' +
    '<div class="dsec"><div class="dsec-title">Evidences (' + evidences.length + ')</div>' + eHtml + '</div>';
}

// ── INSERT FORM ───────────────────────────────────────────────────────────────
function addMetric() {
  var id = mc++;
  var d = document.createElement('div');
  d.className = 'ti'; d.id = 'met-' + id;
  d.innerHTML =
    '<button class="rm" onclick="remove(\'met-' + id + '\')">&#xd7;</button>' +
    '<input type="number" placeholder="ID (uint256)" id="mid-' + id + '" min="0">' +
    '<input type="text"   placeholder="Hash (0x...) ou texto livre" id="mhash-' + id + '">';
  document.getElementById('met-list').appendChild(d);
}

function addEvidence() {
  var id = ec++;
  var d = document.createElement('div');
  d.className = 'ti'; d.id = 'evd-' + id;
  d.innerHTML =
    '<button class="rm" onclick="remove(\'evd-' + id + '\')">&#xd7;</button>' +
    '<input type="number" placeholder="ID (uint256)" id="eid-' + id + '" min="0">' +
    '<input type="text"   placeholder="Hash (0x...) ou texto livre" id="ehash-' + id + '">';
  document.getElementById('evd-list').appendChild(d);
}

function remove(id) {
  var el = document.getElementById(id);
  if (el) el.remove();
}

function collectList(listId) {
  var items = document.getElementById(listId).querySelectorAll('.ti');
  var result = [];
  items.forEach(function(item) {
    var idInp   = item.querySelector('input[type="number"]');
    var hashInp = item.querySelector('input[type="text"]');
    var idVal   = idInp ? idInp.value.trim() : '';
    var hashVal = hashInp ? hashInp.value.trim() : '';
    if (idVal !== '' && hashVal !== '') {
      result.push({ id: idVal, hash: hashVal });
    }
  });
  return result;
}

async function doInsert() {
  var key = document.getElementById('inp-key').value.trim();
  if (!key) { setLog('Informe uma chave (int256)', true); return; }

  var metrics   = collectList('met-list');
  var evidences = collectList('evd-list');

  var btn = document.getElementById('btn-ins');
  btn.disabled = true;
  btn.innerHTML = '<span class="spin"></span> Enviando...';
  setLog('<span class="spin"></span> Enviando transacao para a Sepolia...');

  try {
    var res = await fetch('/api/insert', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ key: key, metrics: metrics, evidences: evidences })
    });
    var data = await res.json();
    if (data.error) throw new Error(data.error);

    var ethUrl = 'https://sepolia.etherscan.io/tx/' + data.hash;
    setLog('&#10003; Confirmada no bloco ' + data.blockNumber +
           ' &mdash; <a href="' + ethUrl + '" target="_blank">Ver no Etherscan &#8599;</a>');

    document.getElementById('inp-key').value = '';
    document.getElementById('met-list').innerHTML = '';
    document.getElementById('evd-list').innerHTML = '';
    mc = 0; ec = 0;
    reloadTree();
  } catch(e) {
    setLog('Erro: ' + e.message, true);
  } finally {
    btn.disabled = false;
    btn.innerHTML = '&#9654; Inserir na Blockchain';
  }
}

function setLog(html, isErr) {
  var el = document.getElementById('log-txt');
  el.innerHTML = html;
  el.style.color = isErr ? 'var(--error)' : '';
}
</script>
</body>
</html>`;

// ─── HTTP SERVER ──────────────────────────────────────────────────────────────
const server = createServer(async (req: IncomingMessage, res: ServerResponse) => {
  const url    = new URL(req.url ?? "/", `http://localhost:${PORT}`);
  const method = req.method ?? "GET";

  try {
    // Serve HTML
    if (url.pathname === "/" && method === "GET") {
      res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
      res.end(HTML);
      return;
    }

    // Wallet / network status
    if (url.pathname === "/api/status" && method === "GET") {
      const [balance, network] = await Promise.all([
        provider.getBalance(wallet.address),
        provider.getNetwork(),
      ]);
      sendJson(res, 200, {
        wallet:   wallet.address,
        balance:  ethers.formatEther(balance),
        network:  network.name,
        chainId:  network.chainId.toString(),
        contract: CONTRACT_ADDR,
      });
      return;
    }

    // Full tree traversal
    if (url.pathname === "/api/tree" && method === "GET") {
      const rootId = await contract.root();
      const tree   = await buildTree(rootId);
      sendJson(res, 200, { root: tree });
      return;
    }

    // Insert node
    if (url.pathname === "/api/insert" && method === "POST") {
      const raw = JSON.parse(await readBody(req)) as InsertBody;
      const metrics   = raw.metrics.map(m   => ({ id: BigInt(m.id),   hash: ensureBytes32(m.hash)   }));
      const evidences = raw.evidences.map(e => ({ id: BigInt(e.id),   hash: ensureBytes32(e.hash)   }));
      const tx      = await contract.insert(BigInt(raw.key), metrics, evidences);
      const receipt = await tx.wait();
      sendJson(res, 200, { hash: tx.hash, blockNumber: receipt?.blockNumber ?? null });
      return;
    }

    // Get metrics by key
    if (url.pathname === "/api/metrics" && method === "GET") {
      const key    = url.searchParams.get("key") ?? "0";
      const result = await contract.getMetrics(BigInt(key));
      sendJson(res, 200, Array.from(result).map(m => ({ id: m.id.toString(), hash: m.hash })));
      return;
    }

    // Get evidences by key
    if (url.pathname === "/api/evidences" && method === "GET") {
      const key    = url.searchParams.get("key") ?? "0";
      const result = await contract.getEvidences(BigInt(key));
      sendJson(res, 200, Array.from(result).map(e => ({ id: e.id.toString(), hash: e.hash })));
      return;
    }

    res.writeHead(404);
    res.end("Not Found");
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    sendJson(res, 500, { error: msg });
  }
});

server.listen(PORT, () => {
  console.log("\n\u{1F333} Red-Black Tree UI — Sepolia Testnet");
  console.log("Contrato : " + CONTRACT_ADDR);
  console.log("Wallet   : " + wallet.address);
  console.log("\nAcesse   : http://localhost:" + PORT + "\n");
});

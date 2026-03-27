import { ethers } from "ethers";
import * as dotenv from "dotenv";
import { MerkleTree } from 'merkletreejs';
import keccak256 from 'keccak256';

dotenv.config();

// Interface para facilitar o manuseio dos dados de ancoragem
interface AnchorData {
    batchId: number;
    root: string;
    txHash?: string;
}

async function main() {
    const provider = new ethers.JsonRpcProvider(process.env.AMOY_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);

    const NOTARY_ADDRESS = "0x7a91E2aD045A85E307835753CFd937F9815Cc6BA";
    const abi = [
        "function anchorBatch(uint256 _batchId, bytes32 _merkleRoot) public",
        "function batchProofs(uint256) public view returns (bytes32)"
    ];import { ethers } from "ethers";
import * as dotenv from "dotenv";
import { MerkleTree } from 'merkletreejs';
import keccak256 from 'keccak256';

dotenv.config();

// Interface para facilitar o manuseio dos dados de ancoragem
interface AnchorData {
    batchId: number;
    root: string;
    txHash?: string;
}

async function main() {
    const provider = new ethers.JsonRpcProvider(process.env.AMOY_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);

    const NOTARY_ADDRESS = "0x7a91E2aD045A85E307835753CFd937F9815Cc6BA";
    const abi = [
        "function anchorBatch(uint256 _batchId, bytes32 _merkleRoot) public",
        "function batchProofs(uint256) public view returns (bytes32)"
    ];

    const notaryContract = new ethers.Contract(NOTARY_ADDRESS, abi, wallet);

    // --- 1. Exemplo de Registro (Ancoragem) ---
    async function anchor(batchId: number, merkleRoot: string): Promise<AnchorData> {
        console.log(`⚓ Ancorando Batch ${batchId}...`);
        const tx = await notaryContract.anchorBatch(batchId, merkleRoot);
        await tx.wait();
        console.log(`✅ Sucesso! Hash da transação: ${tx.hash}`);
        return { batchId, root: merkleRoot, txHash: tx.hash };
    }

    // --- 2. Exemplo de Verificação (Auditoria) ---
    async function verify(batchId: number, originalHashes: string[]) {
        console.log(`\n🔍 Verificando integridade do Batch ${batchId}...`);

        // Busca a raiz registrada no contrato
        const rootOnChain = await notaryContract.batchProofs(batchId);

        // Recria a árvore localmente para comparar
        const leaves = originalHashes.map(h => keccak256(h));
        const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
        const localRoot = tree.getHexRoot();

        if (rootOnChain === localRoot) {
            console.log("🛡️  INTEGRIDADE CONFIRMADA: Os dados locais conferem com a âncora na Amoy!");
        } else {
            console.log("⚠️  ALERTA DE FRAUDE: Os dados foram alterados ou o Batch ID está incorreto.");
        }
    }

    // Teste prático:
    const hashesFicticios = ["0xabc...", "0xdef..."];
    const rootExemplo = new MerkleTree(hashesFicticios.map(keccak256), keccak256, { sortPairs: true }).getHexRoot();

    const res = await anchor(Math.floor(Date.now() / 1000), rootExemplo);
    await verify(res.batchId, hashesFicticios);
}

main().catch(console.error);

    const notaryContract = new ethers.Contract(NOTARY_ADDRESS, abi, wallet);

    // --- 1. Exemplo de Registro (Ancoragem) ---
    async function anchor(batchId: number, merkleRoot: string): Promise<AnchorData> {
        console.log(`⚓ Ancorando Batch ${batchId}...`);
        const tx = await notaryContract.anchorBatch(batchId, merkleRoot);
        await tx.wait();
        console.log(`✅ Sucesso! Hash da transação: ${tx.hash}`);
        return { batchId, root: merkleRoot, txHash: tx.hash };
    }

    // --- 2. Exemplo de Verificação (Auditoria) ---
    async function verify(batchId: number, originalHashes: string[]) {
        console.log(`\n🔍 Verificando integridade do Batch ${batchId}...`);

        // Busca a raiz registrada no contrato
        const rootOnChain = await notaryContract.batchProofs(batchId);

        // Recria a árvore localmente para comparar
        const leaves = originalHashes.map(h => keccak256(h));
        const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
        const localRoot = tree.getHexRoot();

        if (rootOnChain === localRoot) {
            console.log("🛡️  INTEGRIDADE CONFIRMADA: Os dados locais conferem com a âncora na Amoy!");
        } else {
            console.log("⚠️  ALERTA DE FRAUDE: Os dados foram alterados ou o Batch ID está incorreto.");
        }
    }

    // Teste prático:
    const hashesFicticios = ["0xabc...", "0xdef..."];
    const rootExemplo = new MerkleTree(hashesFicticios.map(keccak256), keccak256, { sortPairs: true }).getHexRoot();

    const res = await anchor(Math.floor(Date.now() / 1000), rootExemplo);
    await verify(res.batchId, hashesFicticios);
}

main().catch(console.error);

import { ethers } from "ethers";
import * as fs from "fs";
import * as path from "path";
import * as readline from "readline/promises";
import * as dotenv from "dotenv";
import { MerkleTree } from 'merkletreejs';
import keccak256 from 'keccak256';

dotenv.config({ path: path.resolve('../.env') });

const SEPOLIA_URL = process.env.SEPOLIA_URL || "";
const AMOY_URL = process.env.AMOY_URL || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const PUBLICK_NOTARY_CONTRACT_ADDRESS = "0x7a91E2aD045A85E307835753CFd937F9815Cc6BA";

async function main() {
    if (!SEPOLIA_URL || !AMOY_URL || !PRIVATE_KEY) {
        console.error("❌ Erro: URLs ou PRIVATE_KEY não encontradas.");
        process.exit(1);
    }

    const NOME_DO_CONTRATO = "MultiCalculator";
    const abiPath = path.resolve(`./abis/${NOME_DO_CONTRATO}.json`);
    
    // ABI simplificada para o Notário na Amoy (ajuste conforme seu contrato real)
    const notaryAbi = ["function anchorBatch(uint256 _batchId, bytes32 _merkleRoot) public"];

    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    const contractAddress = (await rl.question("📍 Endereço do contrato Sepolia: ")).trim();

    try {
        const abi = JSON.parse(fs.readFileSync(abiPath, 'utf8')).abi;
        
        // Configuração Sepolia
        const providerSepolia = new ethers.JsonRpcProvider(SEPOLIA_URL);
        const walletSepolia = new ethers.Wallet(PRIVATE_KEY, providerSepolia);
        const contractSepolia = new ethers.Contract(contractAddress, abi, walletSepolia);

        // Configuração Amoy
        const providerAmoy = new ethers.JsonRpcProvider(AMOY_URL);
        const walletAmoy = new ethers.Wallet(PRIVATE_KEY, providerAmoy);
        const contractAmoy = new ethers.Contract(PUBLICK_NOTARY_CONTRACT_ADDRESS, notaryAbi, walletAmoy);

        // Lista para armazenar os hashes das transações
        let transactionHashes: string[] = [];

        let running = true;
        while (running) {
            console.log(`\n--- 🖥️  Menu (Sepolia) ---`);
            console.log(`[1] Criar Novo ID`);
            console.log(`[2] Realizar Operação`);
            console.log(`[0] Sair e Gerar Prova na Amoy`);
            const op = await rl.question("\n👉 Escolha uma opção: ");

            if (op === "1") {
                console.log("⏳ Gerando novo ID na blockchain...");
                const tx = await contractSepolia.create_instance?.();
                const receipt = await tx.wait();
                
                // Opcional: Pegar o valor retornado via eventos ou nova consulta
                console.log(`✅ Novo ID criado! Verifique o log ou consulte o contador.`);

                transactionHashes.push(tx.hash); // Salva o hash
                console.log(`✅ Operação registrada.`);
            } 
            else if (op === "2") {
                const id = await rl.question("🆔 Digite o ID de rastreamento: ");
                console.log("\n[+] Somar | [-] Subtrair | [*] Multiplicar | [/] Dividir");
                const acao = await rl.question("👉 Escolha a operação: ");
                
                const n1 = await rl.question("🔢 Número 1: ");
                const n2 = await rl.question("🔢 Número 2: ");

                let tx;
                if (acao === "+") tx = await contractSepolia.add?.(id, n1, n2);
                else if (acao === "-") tx = await contractSepolia.sub?.(id, n1, n2);
                else if (acao === "*") tx = await contractSepolia.mult?.(id, n1, n2);
                else if (acao === "/") tx = await contractSepolia.div?.(id, n1, n2);
                else throw new Error("Operação inválida");

                console.log(`⏳ Processando transação... ${tx.hash}`);
                await tx.wait();
                
                const res = await contractSepolia.get?.(id);
                console.log(`\n✅ Sucesso! Resultado no ID ${id}: ${res.toString()}`);

                transactionHashes.push(tx.hash); // Salva o hash
                console.log(`✅ Operação registrada.`);
            }
            else if (op == "3") {
                const id = await rl.question("🆔 Digite o ID de rastreamento: ");
                const res = await contractSepolia.get?.(id);
                console.log(`\n✅ Sucesso! Resultado no ID ${id}: ${res.toString()}`);
            } else if (op === "0") {
                running = false;
            }
        }

        // --- PROCESSO DE ANCORAGEM (HYBRID BLOCKCHAIN) ---
        if (transactionHashes.length > 0) {
            console.log(`\nGerando Merkle Root para ${transactionHashes.length} transações...`);

            // 1. Criar as folhas (hashes)
            const leaves = transactionHashes.map(hash => keccak256(hash));
            
            // 2. Gerar a Merkle Tree
            const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
            const root = tree.getHexRoot();

            console.log(`🌿 Merkle Root gerado: ${root}`);
            console.log(`🚀 Enviando prova para a rede pública (Amoy)...`);

            // 3. Enviar para Amoy (usando timestamp como BatchID simplificado)
            const batchId = Math.floor(Date.now() / 1000);
            const txAmoy = await contractAmoy.anchorBatch?.(batchId, root);
            
            console.log(`⏳ Aguardando confirmação na Amoy: ${txAmoy.hash}`);
            await txAmoy.wait();
            
            console.log(`\n🏆 SUCESSO! Transações da Sepolia ancoradas na Amoy.`);
            console.log(`Batch ID: ${batchId}`);
        } else {
            console.log("\nNenhuma transação realizada para ancorar.");
        }

    } catch (error: any) {
        console.error("\n❌ Erro:", error.message);
    } finally {
        rl.close();
    }
}

main().catch(console.error);
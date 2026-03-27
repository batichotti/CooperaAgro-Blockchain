import { ethers } from "ethers";
import * as fs from "fs";
import * as path from "path";
import * as readline from "readline/promises";
import * as dotenv from "dotenv";
import { MerkleTree } from 'merkletreejs';
import keccak256 from 'keccak256';

dotenv.config({ path: path.resolve('../.env') });

// Interfaces para o contrato CooperaAgro
interface Item {
    id_produto: number | bigint;
    qtd: number | bigint;
}

const SEPOLIA_URL = process.env.SEPOLIA_URL || "";
const AMOY_URL = process.env.AMOY_URL || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const NOTARY_CONTRACT_ADDRESS = "0x7a91E2aD045A85E307835753CFd937F9815Cc6BA";

async function main() {
    if (!SEPOLIA_URL || !AMOY_URL || !PRIVATE_KEY) {
        console.error("❌ Erro: Configurações de ambiente ausentes.");
        process.exit(1);
    }

    const abiPath = path.resolve(`./abis/CooperaAgro.json`);
    const notaryAbi = ["function anchorBatch(uint256 _batchId, bytes32 _merkleRoot) public"];
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

    try {
        const abi = JSON.parse(fs.readFileSync(abiPath, 'utf8')).abi;

        // Providers e Wallets
        const walletSepolia = new ethers.Wallet(PRIVATE_KEY, new ethers.JsonRpcProvider(SEPOLIA_URL));
        const walletAmoy = new ethers.Wallet(PRIVATE_KEY, new ethers.JsonRpcProvider(AMOY_URL));

        const contractAddress = (await rl.question("📍 Endereço do contrato CooperaAgro (Sepolia): ")).trim();
        const contractSepolia = new ethers.Contract(contractAddress, abi, walletSepolia);
        const contractAmoy = new ethers.Contract(NOTARY_CONTRACT_ADDRESS, notaryAbi, walletAmoy);

        let transactionHashes: string[] = [];
        let running = true;

        while (running) {
            console.log(`\n--- 🌾 Menu CooperaAgro (Sepolia) ---`);
            console.log(`[1] Produtor: Ofertar Produtos`);
            console.log(`[2] Cooperativa: Comprar Oferta`);
            console.log(`[3] Produtor: Enviar Pacote`);
            console.log(`[4] Cooperativa: Confirmar Recebimento`);
            console.log(`[5] Cooperativa: Enviar para Escola`);
            console.log(`[6] Escola: Confirmar Entrega`);
            console.log(`[7] Consultar Estado do Contrato`);
            console.log(`[0] Sair e Ancorar na Amoy`);

            const op = await rl.question("\n👉 Escolha uma opção: ");

            // Função auxiliar para montar itens via CLI
            const montarItens = async (): Promise<Item[]> => {
                const itens: Item[] = [];
                const qtdItens = parseInt(await rl.question("Quantos produtos diferentes? "));
                for (let i = 0; i < qtdItens; i++) {
                    const id = await rl.question(`ID do Produto ${i+1}: `);
                    const qtd = await rl.question(`Quantidade do Produto ${i+1}: `);
                    itens.push({ id_produto: BigInt(id), qtd: BigInt(qtd) });
                }
                return itens;
            };

            let tx;

            switch (op) {
                case "1":
                    const idC1 = await rl.question("ID do Contrato: ");
                    const idProd = await rl.question("ID do Produtor: ");
                    const oferta = await montarItens();
                    tx = await contractSepolia.produtorOfertar(idC1, idProd, oferta);
                    break;

                case "2":
                    const idC2 = await rl.question("ID do Contrato: ");
                    const idCoop = await rl.question("ID da Cooperativa: ");
                    const compra = await montarItens();
                    const valores = (await rl.question("Valores (separados por vírgula): ")).split(',').map(v => BigInt(v.trim()));
                    tx = await contractSepolia.cooperativaComprar(idC2, idCoop, compra, valores);
                    break;

                case "3":
                    const idC3 = await rl.question("ID do Contrato: ");
                    const pacoteProd = await montarItens();
                    tx = await contractSepolia.produtorEnviarPacote(idC3, pacoteProd);
                    break;

                case "5":
                    const idC5 = await rl.question("ID do Contrato: ");
                    const idEscola = await rl.question("ID da Escola: ");
                    const pacoteEsc = await montarItens();
                    tx = await contractSepolia.cooperativaEnviarPacote(idC5, idEscola, pacoteEsc);
                    break;

                case "7":
                    const idC7 = await rl.question("ID do Contrato para consulta: ");
                    const estado = await contractSepolia.estados(idC7);
                    console.log(`\n📊 Estado Atual: ${estado} (Veja o Enum no Solidity)`);
                    continue;

                case "0":
                    running = false;
                    continue;

                default:
                    console.log("Opção inválida.");
                    continue;
            }

            if (tx) {
                console.log(`⏳ Processando: ${tx.hash}`);
                await tx.wait();
                transactionHashes.push(tx.hash);
                console.log(`✅ Transação confirmada e registrada para ancoragem.`);
            }
        }

        // --- ANCORAGEM (MESMA LÓGICA DO SEU ORIGINAL) ---
        if (transactionHashes.length > 0) {
            console.log(`\n🌿 Gerando Prova de Merkle para ${transactionHashes.length} transações...`);
            const leaves = transactionHashes.map(hash => keccak256(hash));
            const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
            const root = tree.getHexRoot();

            const batchId = Math.floor(Date.now() / 1000);
            const txAmoy = await contractAmoy.anchorBatch(batchId, root);
            await txAmoy.wait();

            console.log(`\n🏆 ANCORAGEM CONCLUÍDA!`);
            console.log(`Merkle Root: ${root}`);
            console.log(`Hash Amoy: ${txAmoy.hash}`);
        }

    } catch (error: any) {
        console.error("\n❌ Erro na operação:", error.reason || error.message);
    } finally {
        rl.close();
    }
}

main().catch(console.error);

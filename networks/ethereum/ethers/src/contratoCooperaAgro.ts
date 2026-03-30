import { ethers } from "ethers";
import * as fs from "fs";
import * as path from "path";
import * as readline from "readline/promises";
import * as dotenv from "dotenv";

dotenv.config({ path: path.resolve('./.env') });

interface Item {
    id_produto: number | bigint;
    qtd: number | bigint;
}

const SEPOLIA_URL = process.env.AMOY_URL || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

async function main() {
    if (!SEPOLIA_URL || !PRIVATE_KEY) {
        console.error("❌ Erro: Configurações de ambiente ausentes.");
        process.exit(1);
    }

    const abiPath = path.resolve(`./abis/CooperaAgro.json`);
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

    try {
        const abi = JSON.parse(fs.readFileSync(abiPath, 'utf8')).abi;
        const provider = new ethers.JsonRpcProvider(SEPOLIA_URL);
        const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

        const contractAddress = (await rl.question("📍 Endereço do contrato CooperaAgro (Sepolia): ")).trim();
        const contractSepolia = new ethers.Contract(contractAddress, abi, wallet);

        let running = true;

        const montarItens = async (): Promise<Item[]> => {
            const itens: Item[] = [];
            const inputQtd = await rl.question("Quantos produtos diferentes? ");
            const qtdItens = parseInt(inputQtd);
            for (let i = 0; i < qtdTrabalhada(qtdItens); i++) {
                const id = await rl.question(`ID do Produto ${i + 1}: `);
                const qtd = await rl.question(`Quantidade do Produto ${i + 1}: `);
                itens.push({ id_produto: BigInt(id), qtd: BigInt(qtd) });
            }
            return itens;
        };

        // Função auxiliar para evitar repetição de código no loop
        function qtdTrabalhada(n: number) { return isNaN(n) ? 0 : n; }

        while (running) {
            console.log(`\n--- 🌾 Menu CooperaAgro (Sepolia) ---`);
            console.log(`[1] Produtor: Ofertar Produtos`);
            console.log(`[2] Cooperativa: Comprar Oferta`);
            console.log(`[3] Produtor: Enviar Pacote`);
            console.log(`[4] Cooperativa: Confirmar Recebimento`);
            console.log(`[5] Cooperativa: Enviar para Escola`);
            console.log(`[6] Escola: Confirmar Entrega`);
            console.log(`[7] Consultar Estado do Contrato`);
            console.log(`[0] Sair`);

            const op = await rl.question("\n👉 Escolha uma opção: ");
            let tx;

            switch (op) {
                case "1": {
                    const idC = await rl.question("ID do Contrato: ");
                    const idProd = await rl.question("ID do Produtor: ");
                    const oferta = await montarItens();
                    tx = await contractSepolia.produtorOfertar(idC, idProd, oferta);
                    break;
                }
                case "2": {
                    const idC = await rl.question("ID do Contrato: ");
                    const idCoop = await rl.question("ID da Cooperativa: ");
                    const compra = await montarItens();
                    const valInput = await rl.question("Valores (separados por vírgula): ");
                    const valores = valInput.split(',').map(v => BigInt(v.trim()));
                    tx = await contractSepolia.cooperativaComprar(idC, idCoop, compra, valores);
                    break;
                }
                case "3": {
                    const idC = await rl.question("ID do Contrato: ");
                    const pacote = await montarItens();
                    tx = await contractSepolia.produtorEnviarPacote(idC, pacote);
                    break;
                }
                case "4": {
                    const idC = await rl.question("ID do Contrato: ");
                    console.log("Itens recebidos pela Cooperativa:");
                    const pacote = await montarItens();
                    tx = await contractSepolia.cooperativaConfirmarEntrega(idC, pacote);
                    break;
                }
                case "5": {
                    const idC = await rl.question("ID do Contrato: ");
                    const idEscola = await rl.question("ID da Escola: ");
                    const pacote = await montarItens();
                    tx = await contractSepolia.cooperativaEnviarPacote(idC, idEscola, pacote);
                    break;
                }
                case "6": {
                    const idC = await rl.question("ID do Contrato: ");
                    const idEscola = await rl.question("ID da Escola: ");
                    const pacote = await montarItens();
                    const sobra = (await rl.question("Tem sobra no estoque? (s/n): ")).toLowerCase() === 's';
                    tx = await contractSepolia.escolaConfirmarEntrega(idC, idEscola, pacote, sobra);
                    break;
                }
                case "7": {
                    const idC = await rl.question("ID do Contrato para consulta: ");
                    const estado = await contractSepolia.estados(idC);
                    const estadosEnum = [
                        "CONTRATO_CRIADO", "PRODUTOS_OFERTADOS", "PRODUTOS_COMPRADOS",
                        "PACOTE_ENVIADO_PARA_COOPERATIVA", "PACOTE_RECEBIDO_PELA_COOPERATIVA",
                        "ENVIANDO_PACOTES_PARA_ESCOLAS", "TODOS_PACOTES_RECEBIDO_PELAS_ESCOLAS"
                    ];
                    console.log(`\n📊 Estado Atual: ${estado} (${estadosEnum[Number(estado)] || "Desconhecido"})`);
                    continue;
                }
                case "0":
                    running = false;
                    continue;
                default:
                    console.log("Opção inválida.");
                    continue;
            }

            if (tx) {
                console.log(`⏳ Processando transação: ${tx.hash}`);
                await tx.wait();
                console.log(`✅ Transação confirmada!`);
            }
        }
    } catch (error: any) {
        console.error("\n❌ Erro na operação:", error.reason || error.message);
    } finally {
        rl.close();
    }
}

main().catch(console.error);
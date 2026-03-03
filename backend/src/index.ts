import { ethers } from "ethers";
import * as fs from "fs";
import * as path from "path";
import * as readline from "readline/promises";
import * as dotenv from "dotenv";

dotenv.config({ path: path.resolve('../.env') });

const SEPOLIA_URL = process.env.SEPOLIA_URL || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

async function main() {
    if (!SEPOLIA_URL || !PRIVATE_KEY) {
        console.error("❌ Erro: SEPOLIA_URL ou PRIVATE_KEY não encontradas.");
        process.exit(1);
    }

    const NOME_DO_CONTRATO = "MultiCalculator";
    const abiPath = path.resolve(`./abis/${NOME_DO_CONTRATO}.json`);

    if (!fs.existsSync(abiPath)) {
        console.error(`❌ Erro: ABI ${NOME_DO_CONTRATO}.json não encontrada.`);
        process.exit(1);
    }

    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

    console.log(`\n--- 🖥️  Backend CooperaAgro: ${NOME_DO_CONTRATO} ---`);
    const contractAddress = (await rl.question("📍 Endereço do contrato: ")).trim();

    try {
        const abi = JSON.parse(fs.readFileSync(abiPath, 'utf8')).abi;
        const provider = new ethers.JsonRpcProvider(SEPOLIA_URL);
        const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
        const contract = new ethers.Contract(contractAddress, abi, wallet);

        console.log(`\n[1] Criar Novo ID (create_instance)`);
        console.log(`[2] Realizar Operação em ID existente`);
        console.log(`[3] Obtem o Número Gravado no ID existente`);
        const op = await rl.question("\n👉 Escolha uma opção: ");

        if (op === "1") {
            console.log("⏳ Gerando novo ID na blockchain...");
            const tx = await contract.create_instance();
            const receipt = await tx.wait();
            
            // Opcional: Pegar o valor retornado via eventos ou nova consulta
            console.log(`✅ Novo ID criado! Verifique o log ou consulte o contador.`);
        } 
        else if (op === "2") {
            const id = await rl.question("🆔 Digite o ID de rastreamento: ");
            console.log("\n[+] Somar | [-] Subtrair | [*] Multiplicar | [/] Dividir");
            const acao = await rl.question("👉 Escolha a operação: ");
            
            const n1 = await rl.question("🔢 Número 1: ");
            const n2 = await rl.question("🔢 Número 2: ");

            let tx;
            if (acao === "+") tx = await contract.add(id, n1, n2);
            else if (acao === "-") tx = await contract.sub(id, n1, n2);
            else if (acao === "*") tx = await contract.mult(id, n1, n2);
            else if (acao === "/") tx = await contract.div(id, n1, n2);
            else throw new Error("Operação inválida");

            console.log(`⏳ Processando transação... ${tx.hash}`);
            await tx.wait();
            
            const res = await contract.get(id);
            console.log(`\n✅ Sucesso! Resultado no ID ${id}: ${res.toString()}`);
        }
        else if (op == "3") {
            const id = await rl.question("🆔 Digite o ID de rastreamento: ");
            const res = await contract.get(id);
            console.log(`\n✅ Sucesso! Resultado no ID ${id}: ${res.toString()}`);
        }

    } catch (error: any) {
        console.error("\n❌ Erro na operação:");
        // Captura os erros customizados do seu Solidity (InvalidId, DivisionByZero, etc)
        console.error(error.reason || error.message);
    } finally {
        rl.close();
    }
}

main().catch(console.error);
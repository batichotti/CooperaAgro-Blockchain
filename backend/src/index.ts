import { ethers } from "ethers";
import * as fs from "fs";
import * as path from "path";
import * as readline from "readline/promises";
import * as dotenv from "dotenv";

// 1. Configuração do ambiente
dotenv.config({ path: path.resolve('.env') });

const SEPOLIA_URL = process.env.SEPOLIA_URL || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

async function main() {
    if (!SEPOLIA_URL || !PRIVATE_KEY) {
        console.error("❌ Erro: SEPOLIA_URL ou PRIVATE_KEY não encontradas no .env.");
        process.exit(1);
    }

    // 2. Configuração do Nome do Contrato (deve ser Calculator)
    const NOME_DO_CONTRATO = "Calculator";
    const abiPath = path.resolve(`./abis/${NOME_DO_CONTRATO}.json`);

    if (!fs.existsSync(abiPath)) {
        console.error(`❌ Erro: ABI não encontrada em ${abiPath}`);
        console.error("Execute 'npm run copy-abi' na pasta do backend.");
        process.exit(1);
    }

    // 3. Interface de entrada
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    console.log(`\n--- 🖥️  Backend CooperaAgro: Módulo ${NOME_DO_CONTRATO} ---`);

    const addressInput = await rl.question("📍 Cole o endereço do contrato Calculator (0x...): ");
    const contractAddress = addressInput.trim();

    if (!ethers.isAddress(contractAddress)) {
        console.error("❌ Erro: Endereço inválido.");
        rl.close();
        process.exit(1);
    }

    // Perguntar os números para a soma
    const n1 = await rl.question("🔢 Digite o primeiro número: ");
    const n2 = await rl.question("🔢 Digite o segundo número: ");
    
    rl.close();

    try {
        // 4. Inicialização
        const contractFile = fs.readFileSync(abiPath, 'utf8');
        const abi = JSON.parse(contractFile).abi;

        const provider = new ethers.JsonRpcProvider(SEPOLIA_URL);
        const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
        const contract = new ethers.Contract(contractAddress, abi, wallet);

        console.log(`\n🔗 Conectado à Sepolia | Carteira: ${wallet.address}`);

        // 5. Executando a SOMA (Escrita - Gasta Gás)
        console.log(`\n⏳ Enviando transação: add(${n1}, ${n2})...`);
        
        // Convertendo para BigInt para o ethers lidar com uint256 do Solidity
        const tx = await contract.add(BigInt(n1), BigInt(n2));
        
        console.log(`📡 Transação enviada! Hash: ${tx.hash}`);
        console.log("⏳ Aguardando confirmação do bloco...");
        
        await tx.wait(); // Espera a mineração
        console.log("✅ Transação confirmada com sucesso!");

        // 6. Lendo o resultado (Leitura - Grátis)
        console.log("\n🔍 Consultando 'ultimo_resultado' no contrato...");
        const resultado = await contract.get();

        console.log("------------------------------------------");
        console.log(`📊 RESULTADO DA SOMA: ${resultado.toString()}`);
        console.log("------------------------------------------\n");

    } catch (error: any) {
        console.error("\n❌ Erro na operação:");
        console.error(error.reason || error.message || error);
    }
}

main().catch((error) => {
    console.error("Erro crítico:", error);
    process.exit(1);
});
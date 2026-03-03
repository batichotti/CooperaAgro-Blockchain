import { ethers } from "ethers";
import * as fs from "fs";
import * as path from "path";
import * as readline from "readline/promises";

// Carrega o .env que está na raiz do projeto
import * as dotenv from "dotenv";
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const RPC_URL = process.env.SEPOLIA_RPC_URL || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

async function main() {
    if (!RPC_URL || !PRIVATE_KEY) {
        throw new Error("Verifique o .env! RPC_URL e PRIVATE_KEY são obrigatórios.");
    }

    // 1. Identificar a pasta abis/ e listar os contratos
    const abisDir = path.resolve(__dirname, './abis');
    if (!fs.existsSync(abisDir)) {
        console.error("❌ Pasta abis/ não encontrada. Rode 'npm run copy-abi' primeiro.");
        return;
    }

    // Pega apenas os arquivos .json, ignorando arquivos de debug que o Foundry pode gerar
    const files = fs.readdirSync(abisDir).filter(f => f.endsWith('.json') && !f.endsWith('.dbg.json'));

    if (files.length === 0) {
        console.log("❌ Nenhum contrato encontrado na pasta abis/.");
        return;
    }

    // 2. Configurar o menu interativo no terminal
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    console.log("\n📦 === Contratos Disponíveis ===");
    files.forEach((file, index) => {
        console.log(`[${index}] - ${file.replace('.json', '')}`);
    });

    const choice = await rl.question("\n👉 Digite o número do contrato que deseja testar: ");
    const selectedIndex = parseInt(choice);

    if (isNaN(selectedIndex) || selectedIndex < 0 || selectedIndex >= files.length) {
        console.log("❌ Opção inválida.");
        rl.close();
        return;
    }

    const selectedFile = files[selectedIndex];
    const contractName = selectedFile.replace('.json', '');
    console.log(`\n✅ Você selecionou: ${contractName}`);

    // 3. Pedir o endereço do contrato na rede
    const addressInput = await rl.question("📍 Cole o endereço do contrato (0x...): ");
    const contractAddress = addressInput.trim();

    if (!contractAddress.startsWith('0x') || contractAddress.length !== 42) {
        console.log("❌ Endereço inválido.");
        rl.close();
        return;
    }

    // Fecha a interface de digitação
    rl.close();

    // 4. Carregar a ABI escolhida e conectar
    const abiPath = path.join(abisDir, selectedFile);
    const contractJson = JSON.parse(fs.readFileSync(abiPath, 'utf8'));
    const abi = contractJson.abi;

    const provider = new ethers.JsonRpcProvider(RPC_URL);
    const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
    const contract = new ethers.Contract(contractAddress, abi, wallet);

    console.log(`\n📡 Conectado! Carteira: ${wallet.address}`);
    console.log(`🔗 Contrato alvo: ${contractAddress}`);

    // 5. Executar lógicas específicas dependendo do contrato escolhido
    try {
        if (contractName === 'HelloWorld') {
            console.log("\n--- 🚀 Iniciando testes do HelloWorld ---");
            const current = await contract.getGreeting();
            console.log(`🔍 Mensagem atual na rede: "${current}"`);

            console.log("✍️  Atualizando mensagem (aguardando mineração)...");
            const tx = await contract.setGreeting(`Atualizado pelo terminal as ${new Date().toLocaleTimeString()}`);
            await tx.wait();

            const updated = await contract.getGreeting();
            console.log(`✅ Nova mensagem confirmada: "${updated}"\n`);

        } else if (contractName === 'TrackingCertification') {
            console.log("\n--- 🚛 Iniciando testes do TrackingCertification ---");
            console.log("A instância está pronta! Adicione as chamadas de registerCollection aqui.");

        } else {
            console.log("\n✅ Contrato carregado com sucesso na memória.");
            console.log("Para testar as funções dele, adicione um bloco 'else if' no index.ts.");
        }
    } catch (error) {
        console.error("\n❌ Erro ao interagir com a blockchain:", error);
    }
}

main();

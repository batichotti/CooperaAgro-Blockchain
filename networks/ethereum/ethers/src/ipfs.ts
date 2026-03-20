import { PinataSDK } from "pinata-web3";
import fs from "fs";
import path from "path";
import * as dotenv from "dotenv";

dotenv.config();

const pinata = new PinataSDK({
  pinataJwt: process.env.PINATA_JWT!,
});

async function uploadImage(imagePath: string) {
  const fileName = path.basename(imagePath);
  const fileBytes = fs.readFileSync(imagePath);
  const file = new File([fileBytes], fileName, { type: "image/jpeg" });

  console.log(`📤 Enviando ${fileName}...`);

  const result = await pinata.upload.file(file);

  console.log("✅ Upload concluído!");
  console.log("   CID:", result.IpfsHash);
  console.log("   URL:", `https://gateway.pinata.cloud/ipfs/${result.IpfsHash}`);
}

async function uploadJson(jsonData: object | string, fileName: string = "metadata.json") {
  let file: File;

  if (typeof jsonData === "string" && fs.existsSync(jsonData)) {
    // Upload from existing JSON file
    const fileBytes = fs.readFileSync(jsonData);
    file = new File([fileBytes], path.basename(jsonData), { type: "application/json" });
  } else {
    // Upload from object
    const jsonString = typeof jsonData === "string" ? jsonData : JSON.stringify(jsonData);
    file = new File([jsonString], fileName, { type: "application/json" });
  }

  console.log(`📤 Enviando ${file.name}...`);

  const result = await pinata.upload.file(file);

  console.log("✅ Upload concluído!");
  console.log("   CID:", result.IpfsHash);
  console.log("   URL:", `https://gateway.pinata.cloud/ipfs/${result.IpfsHash}`);
}

async function getFile(cid: string, outputPath: string) {
  console.log(`🔍 Buscando arquivo com CID: ${cid}`);

  const response = await fetch(`https://gateway.pinata.cloud/ipfs/${cid}`);

  if (!response.ok) {
    throw new Error(`Erro ao buscar arquivo: ${response.status} ${response.statusText}`);
  }

  const buffer = Buffer.from(await response.arrayBuffer());
  fs.writeFileSync(outputPath, buffer);

  console.log("✅ Arquivo salvo em:", outputPath);
}

uploadJson("../src/privado/MRV/metadata.json").catch(console.error);

//uploadImage("public/res/test/test.jpg").catch(console.error);

//Image CID: bafybeifh54tx4yu6jzsqskersfc2jcinpap35pruz6q5eg36lbtq2u65y4
// JSON CID: bafkreihlpyae6n6ixdxxddvumuajdibjpe2wfsdenls2yeci4j3fg6i4vu
// getFile("bafybeifh54tx4yu6jzsqskersfc2jcinpap35pruz6q5eg36lbtq2u65y4", "public/res/test/test_retrived.jpg").catch(console.error);
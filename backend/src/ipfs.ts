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

uploadImage("public/res/test/test.jpg").catch(console.error);

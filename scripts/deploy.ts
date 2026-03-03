import { network } from "hardhat";

const { viem, networkName } = await network.connect();
const publicClient = await viem.getPublicClient();

console.log(`Deploying CooperaAgro to ${networkName}...`);

// se seu constructor for vazio:
const cooperaAgro = await viem.deployContract("CooperaAgro");

console.log("Contract address:", cooperaAgro.address);

console.log("Deployment successful!");

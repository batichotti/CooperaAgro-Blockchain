## Ethers.js

**Ethers.js is a complete, compact and secure library for interacting with the Ethereum Blockchain and its ecosystem, written in TypeScript and JavaScript.**

Ethers consists of:

- **Provider**: A read-only connection to the Ethereum network (RPC abstraction).
- **Signer**: An abstraction of an Ethereum account, used to sign messages and transactions (Wallet).
- **Contract**: An abstraction of a smart contract deployed on the network.
- **Utils**: Essential tools for formatting data, handling BigInt and unit conversions.

## Documentation

https://docs.ethers.org/

## Usage

### Install

```shell
$ npm install ethers
```

### Code Example
```javascript
import { ethers } from "ethers";

// 1. Conexão com a rede
const provider = new ethers.JsonRpcProvider("SUA_RPC_URL");

// 2. Signer (Sua carteira para assinar transações)
const wallet = new ethers.Wallet("SUA_PRIVATE_KEY", provider);

// 3. ABI (Human-Readable) - Use o mesmo nome da função do Solidity
const abi = [
  "function store(uint256 num) public",
  "function retrieve() public view returns (uint256)"
];

// 4. Instância do Contrato
const contract = new ethers.Contract("0xADDRESS", abi, wallet);

// 5. Chamada de função (exatamente como no contrato .sol)
async function run() {
  const tx = await contract.store(100); // Chama a função 'store' do Solidity
  await tx.wait();

  const val = await contract.retrieve(); // Chama a função 'retrieve' do Solidity
  console.log(val.toString());
}
```

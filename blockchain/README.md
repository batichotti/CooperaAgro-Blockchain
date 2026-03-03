# Supply-Blockchain

Smart Contracts and Blockchain environment in practice. In this file, I will explain how to create a Private Local Blockchain.

---

## Local Ethereum Network

### Using Geth on a Linux Server

After establishing an SSH connection, download Geth on your machine. We recommend using an isolated folder to work with it.

First, add the official Ethereum repository:

```bash
sudo add-apt-repository -y ppa:ethereum/ethereum
```

Then, install the stable version of go-ethereum:

```bash
sudo apt-get update
sudo apt-get install ethereum
```

To verify the installation, run:

```bash
geth --version
```

---

### Other Installation Options

<details>
<summary>Development Version</summary>

```bash
sudo apt-get update
sudo apt-get install ethereum-unstable
```

</details>

<details>
<summary>Update Existing Geth</summary>

```bash
sudo apt-get update
sudo apt-get install ethereum
sudo apt-get upgrade geth
```

</details>

<details>
<summary>UNIX-Like Systems and macOS</summary>

```bash
git clone https://github.com/ethereum/go-ethereum.git
cd go-ethereum
make geth
```

</details>

---

## Starting with Geth Puppeth

Blockchains can operate under different consensus mechanisms. The most common are:

- **Proof of Work (PoW)** – Used by Bitcoin and by Ethereum prior to 2022  
- **Proof of Stake (PoS)** – Adopted by Ethereum after its 2022 transition  
- **Proof of Authority (PoA)** – Typically used in private or permissioned blockchain networks  

This guide will use the **Proof of Authority (PoA)** mechanism.

---

### Step 1 — Create Node Accounts

Create the data directories and accounts:

```bash
sudo geth --datadir node1 account new
sudo geth --datadir node2 account new
```

Save the information generated for the created nodes, such as:

- Public address  
- Path to the keystore file  

You will be prompted to enter a password, which will protect your private key.

---

### Step 2 — Configure the Blockchain with Puppeth

Use Puppeth (Geth’s built-in tool):

```bash
sudo puppeth
```

Follow these steps:

- Choose the name of the network  
- Select **[2] Configure new Genesis**  
- Create a genesis from scratch  
- Choose **[2] Clique** (Proof-of-Authority)  
- Define the block time (default is 15 seconds)  
- Specify which accounts are allowed to seal (minimum of 1)  
  - Provide the public addresses **without the `0x` prefix**  
- Add both accounts as pre-funded  
- Enable precompile addresses  
- Specify a custom chain/network ID if desired (e.g., 2000 for MetaMask)  

---

### Step 3 — Export Genesis

Run Puppeth again:

```bash
sudo puppeth
```

Then:

- Select **[2] Manage existing genesis**
- Select **[2] Export genesis configuration**

Copy the exported `genesis.json` file into each node directory.

---

### Step 4 — Initialize Nodes

```bash
geth --datadir node1/ init node1/genesis.json
geth --datadir node2/ init node2/genesis.json
```

The `genesis.json` file will use the network name defined earlier.

---

## Starting with Geth Kurtosis

Reference:  
https://geth.ethereum.org/docs/fundamentals/kurtosis

---

### Install Kurtosis

Install and start the Docker daemon before proceeding.

---

### Ubuntu

```bash
echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | sudo tee /etc/apt/sources.list.d/kurtosis.list
sudo apt update
sudo apt install kurtosis-cli
```

---

### Windows

WSL is recommended, but you can also use PowerShell:

```powershell
Invoke-WebRequest -Uri "https://github.com/kurtosis-tech/kurtosis-cli-release-artifacts/releases/download/REPLACE_VERSION/kurtosis-cli_REPLACE_VERSION_windows_REPLACE_ARCH.tar.gz" -OutFile kurtosis.tar.gz
tar -xvzf kurtosis.tar.gz

$currentDir = Get-Location
$systemPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
if (-not $systemPath.Contains($currentDir)) {
    $newPath = $systemPath + ";" + $currentDir
    [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::Machine)
}

$batchContent = @"
@echo off
kurtosis.exe %*
"@
$batchContent | Out-File "$currentDir\kurtosis.bat"

kurtosis version
```

---

### macOS

```bash
brew install kurtosis-tech/tap/kurtosis-cli
xcode-select --install
```

---

## Kurtosis Quickstart

```bash
kurtosis run github.com/kurtosis-tech/basic-service-package --enclave <NETWORK_NAME>
```

---

## Running a Private Ethereum Network with Kurtosis

Create a `genesis.yaml` file:

```yaml
# 1. Nodes (Execution + Consensus)
participants:
  - el_type: geth
    cl_type: lighthouse
  - el_type: geth
    cl_type: lighthouse

# 2. Network and Genesis
network_params:
  network_id: "<CHAIN_ID>"
  deposit_contract_address: "0x<CONTRACT_ADDRESS>"
  seconds_per_slot: <TIME_STAMP>
  genesis_delay: <TIME_TO_CREATE>
  capella_fork_epoch: 0
  deneb_fork_epoch: 0
  prefunded_accounts: '{ "0x<ETH_ACCOUNT_ADDRESS>": { "balance": "<INITIAL_WEI>" } }'

# 3. Additional Services
additional_services:
  - blockscout
```

Run Kurtosis using the ETHPandaOps Ethereum package:

```bash
kurtosis run --enclave <NETWORK_NAME> github.com/ethpandaops/ethereum-package --args-file genesis.yaml
```

To connect MetaMask, retrieve the network information with:

```bash
kurtosis enclave inspect <NETWORK_NAME>
```

---

## Node.js Alternative

Article reference:  
https://medium.com/better-programming/create-blockchain-with-node-js-e65dfc40479e

---

## Another Way to Create a Private Blockchain

TECHCommunity provides a GitHub repository that simplifies this process:

https://github.com/SoftwareAG/ethereum-private-chain

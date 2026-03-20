# Hyperledger Fabric

## Prerequisites

1. Docker
2. npm (optional)
3. Go-lang (optional)
4. Java (optional)

## Setup

1. Clone fabric-samples
```bash
git clone https://github.com/hyperledger/fabric-samples
```

2. Start Docker containers
```bash
# At the test-network folder
./network.sh up
docker pull hyperledger/fabric-nodeenv:2.5
```

3. Configure environment variables
```bash
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051 # PORT

export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```

## Usage

### Create Channel

1. Create a channel
```bash
./network.sh createChannel -c <CHANNEL_NAME>
```

2. Deploy the chaincode
```bash
./network.sh deployCC \
  -ccn <CONTRACT_NAME> \
  -ccp <CONTRACT_FOLDER> \
  -ccl <go|java|javascript|typescript> \
  -c <CHANNEL_NAME>
```

3. Initialize the ledger
```bash
peer chaincode invoke \
  -o localhost:7050 \ # PORT
  --ordererTLSHostnameOverride orderer.example.com \
  --tls \
  --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
  -C <CHANNEL_NAME> \
  -n <CONTRACT_NAME> \
  --peerAddresses localhost:7051 \ # PORT
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 \ # PORT
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  -c '{"Args":["InitLedger"]}'
```

4. Invoke chaincode write functions
```bash
peer chaincode invoke \
  -o localhost:7050 \ # PORT
  --ordererTLSHostnameOverride orderer.example.com \
  --tls \
  --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
  -C <CHANNEL_NAME> -n <CONTRACT_NAME> \
  --peerAddresses localhost:7051 \ # PORT
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 \ # PORT
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  -c '{"Args":["<FUNCTION_NAME>","<FUNCTION_PARAMETERS>"]}'
```

5. Invoke chaincode read functions
```bash
peer chaincode query \
  -C <CHANNEL_NAME> -n <CONTRACT_NAME> \
  -c '{"Args":["<FUNCTION_NAME>","<ID>"]}'
```
# Hyperledger Fabric

## Pre Requisites

1. Docker

## Setup

1. Clone fabric-samples
```{bash}
git clone https://github.com/hyperledger/fabric-samples
```

2. Dockers up
```{bash}
# At test-networks folder
./network.sh up
docker pull hyperledger/fabric-nodeenv:2.5
```

3. Setting Configs
```{bash}
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

## Use

### Create Channel

1. Creating Channel
```{bash}
./network.sh createChannel -c <CHANNEL_NAME>
```

2. Contract Deploy
```{bash}
./network.sh deployCC \
  -ccn <CONTRACT_NAME> \
  -ccp <CONTRACT_FOLDER> \
  -ccl <go|java|javascript|typescript> \
  -c <CHANNEL_NAME>
```

3. InitLedger
```{bash}
peer chaincode invoke \
  -o localhost:7050 # PORT \ 
  --ordererTLSHostnameOverride orderer.example.com \
  --tls \
  --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
  -C <CHANNEL_NAME> \
  -n <CONTRACT_NAME> \
  --peerAddresses localhost:7051 # PORT \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 # PORT\
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  -c '{"Args":["InitLedger"]}'
```

4. Interacting with Contracts Post Functions
```{bash}
peer chaincode invoke \
  -o localhost:7050 # PORT \
  --ordererTLSHostnameOverride orderer.example.com \
  --tls \
  --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
  -C <CHANNEL_NAME> -n <CONTRACT_NAME> \
  --peerAddresses localhost:7051 # PORT \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 # PORT \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  -c '{"Args":["<FUNCTION_NAME>","<FUNCTIONS_PARAMETERS>"]}'
```

5. Interacting with Contracts Get Functions

```{bash}
peer chaincode query \
  -C <CHANNEL_NAME> -n <CONTRACT_NAME> \
  -c '{"Args":["<FUNCTION_NAME>","<ID>"]}'
```
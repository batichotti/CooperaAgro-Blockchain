package main

import (
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/v2/contractapi"
)

// SmartContract define a estrutura para o contrato
type SmartContract struct {
	contractapi.Contract
}

// SalvarNumero armazena um número associado a uma chave
func (s *SmartContract) SalvarNumero(ctx contractapi.TransactionContextInterface, chave string, valor string) error {
	// PutState grava no Ledger (Banco de Dados de Estado)
	return ctx.GetStub().PutState(chave, []byte(valor) )
}

// LerNumero recupera o número do Ledger
func (s *SmartContract) LerNumero(ctx contractapi.TransactionContextInterface, chave string) (string, error) {
	valorBytes, err := ctx.GetStub().GetState(chave)
	if err != nil {
		return "", fmt.Errorf("falha ao ler do world state: %v", err)
	}
	if valorBytes == nil {
		return "", fmt.Errorf("a chave %s não existe", chave)
	}

	return string(valorBytes), nil
}

func main() {
	contract, err := contractapi.NewChaincode(&SmartContract{})
	if err != nil {
		fmt.Printf("Erro ao criar chaincode: %v", err)
		return
	}

	if err := contract.Start(); err != nil {
		fmt.Printf("Erro ao iniciar chaincode: %v", err)
	}
}

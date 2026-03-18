package main

import (
	"fmt"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/v2/contractapi"
)

// Prova define os dados que serão salvos
type Prova struct {
	IPFSCID      string `json:"ipfs_cid"`
	DataRegistro int64  `json:"data_registro"`
}

type RegistroMRVContract struct {
	contractapi.Contract
}

// RegistrarVerificacao equivale à sua função no Solidity
func (s *RegistroMRVContract) RegistrarVerificacao(ctx contractapi.TransactionContextInterface, idProdutor string, idProducao string, cid string) error {

	// Criamos uma Chave Composta: "Prova~ProdutorID~ProducaoID"
	// Isso organiza os dados no banco de forma que fiquem agrupados por Produtor
	chave, err := ctx.GetStub().CreateCompositeKey("Prova", []string{idProdutor, idProducao})
	if err != nil {
		return fmt.Errorf("falha ao criar chave composta: %v", err)
	}

	prova := Prova{
		IPFSCID:      cid,
		DataRegistro: time.Now().Unix(), // Equivalente ao block.timestamp
	}

	// O Hyperledger Fabric não tem "Events" automáticos como o Solidity,
	// mas você pode emitir um explicitamente:
	eventPayload := fmt.Sprintf(`{"idProdutor":"%s","idProducao":"%s","cid":"%s"}`, idProdutor, idProducao, cid)
	ctx.GetStub().SetEvent("ProvaRegistrada", []byte(eventPayload))

	return s.salvar(ctx, chave, prova)
}

// BuscarProva permite ler um registro específico
func (s *RegistroMRVContract) BuscarProva(ctx contractapi.TransactionContextInterface, idProdutor string, idProducao string) (*Prova, error) {
	chave, _ := ctx.GetStub().CreateCompositeKey("Prova", []string{idProdutor, idProducao})

	bytes, err := ctx.GetStub().GetState(chave)
	if err != nil || bytes == nil {
		return nil, fmt.Errorf("prova não encontrada")
	}

	var p Prova
	// Usamos o helper para converter de bytes para a struct (seria definido abaixo)
	// Para simplificar aqui, imagine o unmarshal direto
	return &p, nil
}

// --- Helpers ---

func (s *RegistroMRVContract) salvar(ctx contractapi.TransactionContextInterface, chave string, p Prova) error {
	// Importante: use json.Marshal para converter a struct em bytes
	return ctx.GetStub().PutState(chave, []byte(fmt.Sprintf(`{"ipfs_cid":"%s","data_registro":%d}`, p.IPFSCID, p.DataRegistro)))
}

func main() {
	cc, _ := contractapi.NewChaincode(&RegistroMRVContract{})
	cc.Start()
}

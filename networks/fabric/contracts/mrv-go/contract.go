package main

import (
	"encoding/json"
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

// =========================
// REGISTRAR
// =========================
func (s *RegistroMRVContract) RegistrarVerificacao(
	ctx contractapi.TransactionContextInterface,
	idProdutor string,
	idProducao string,
	cid string,
) error {

	chave, err := ctx.GetStub().CreateCompositeKey("Prova", []string{idProdutor, idProducao})
	if err != nil {
		return fmt.Errorf("erro ao criar chave: %v", err)
	}

	fmt.Println("SALVANDO CHAVE:", chave)

	prova := Prova{
		IPFSCID:      cid,
		DataRegistro: time.Now().Unix(),
	}

	// Serializa corretamente
	bytes, err := json.Marshal(prova)
	if err != nil {
		return fmt.Errorf("erro ao serializar: %v", err)
	}

	err = ctx.GetStub().PutState(chave, bytes)
	if err != nil {
		return fmt.Errorf("erro ao salvar no ledger: %v", err)
	}

	// Evento
	eventPayload, _ := json.Marshal(map[string]string{
		"idProdutor": idProdutor,
		"idProducao": idProducao,
		"cid":        cid,
	})
	ctx.GetStub().SetEvent("ProvaRegistrada", eventPayload)

	return nil
}

// =========================
// BUSCAR
// =========================
func (s *RegistroMRVContract) BuscarProva(
	ctx contractapi.TransactionContextInterface,
	idProdutor string,
	idProducao string,
) (*Prova, error) {

	chave, err := ctx.GetStub().CreateCompositeKey("Prova", []string{idProdutor, idProducao})
	if err != nil {
		return nil, fmt.Errorf("erro ao criar chave: %v", err)
	}

	fmt.Println("BUSCANDO CHAVE:", chave)

	bytes, err := ctx.GetStub().GetState(chave)
	if err != nil {
		return nil, fmt.Errorf("erro ao acessar ledger: %v", err)
	}
	if bytes == nil {
		return nil, fmt.Errorf("prova não encontrada")
	}

	var prova Prova
	err = json.Unmarshal(bytes, &prova)
	if err != nil {
		return nil, fmt.Errorf("erro ao deserializar: %v", err)
	}

	return &prova, nil
}

// =========================
// MAIN
// =========================
func main() {
	cc, err := contractapi.NewChaincode(&RegistroMRVContract{})
	if err != nil {
		panic(fmt.Sprintf("erro ao criar chaincode: %v", err))
	}

	err = cc.Start()
	if err != nil {
		panic(fmt.Sprintf("erro ao iniciar chaincode: %v", err))
	}
}
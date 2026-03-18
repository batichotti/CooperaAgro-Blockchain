package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/v2/contractapi"
)

// --- Estruturas ---

type Item struct {
	IDProduto string `json:"id_produto"`
	Qtd       int    `json:"qtd"`
}

type ContratoAgro struct {
	ID                  string          `json:"id"`
	Estado              int             `json:"estado"`
	ProdutorID          string          `json:"produtor_id"`
	CooperativaID       string          `json:"cooperativa_id"`
	EscolasIDs          []string        `json:"escolas_ids"`
	Ofertas             []Item          `json:"ofertas"`
	Compras             []Item          `json:"compras"`
	Valores             []int           `json:"valores"`
	EnviadoProdutor     []Item          `json:"enviado_produtor"`
	RecebidoCooperativa  []Item          `json:"recebido_cooperativa"`
	PacotesEscolas      map[string][]Item `json:"pacotes_escolas"`      // id_escola => itens
	RecebidoEscolas     map[string][]Item `json:"recebido_escolas"`     // id_escola => itens
	ConfirmacoesEscolas int             `json:"confirmacoes_escolas"`
}

const (
	CONTRATO_CRIADO = iota
	PRODUTOS_OFERTADOS
	PRODUTOS_COMPRADOS
	PACOTE_ENVIADO_PARA_COOPERATIVA
	PACOTE_RECEBIDO_PELA_COOPERATIVA
	ENVIANDO_PACOTES_PARA_ESCOLAS
	TODOS_PACOTES_RECEBIDOS
)

type SmartContract struct {
	contractapi.Contract
}

// --- Funções Principais ---

func (s *SmartContract) ProdutorOfertar(ctx contractapi.TransactionContextInterface, idContrato string, idProdutor string, ofertaItems string) error {
	var itens []Item
	if err := json.Unmarshal([]byte(ofertaItems), &itens); err != nil {
		return err
	}

	novo := ContratoAgro{
		ID:             idContrato,
		Estado:         PRODUTOS_OFERTADOS,
		ProdutorID:     idProdutor,
		Ofertas:        itens,
		PacotesEscolas: make(map[string][]Item),
		RecebidoEscolas: make(map[string][]Item),
	}

	return s.salvar(ctx, &novo)
}

func (s *SmartContract) CooperativaComprar(ctx contractapi.TransactionContextInterface, idContrato string, idCoop string, compraItems string, valores []int) error {
	c, _ := s.LerContrato(ctx, idContrato)
	if c.Estado != PRODUTOS_OFERTADOS { return fmt.Errorf("estado inválido") }

	json.Unmarshal([]byte(compraItems), &c.Compras)
	c.CooperativaID = idCoop
	c.Valores = valores
	c.Estado = PRODUTOS_COMPRADOS
	return s.salvar(ctx, c)
}

func (s *SmartContract) ProdutorEnviarPacote(ctx contractapi.TransactionContextInterface, idContrato string, pacote string) error {
	c, _ := s.LerContrato(ctx, idContrato)
	if c.Estado != PRODUTOS_COMPRADOS { return fmt.Errorf("estado inválido") }

	json.Unmarshal([]byte(pacote), &c.EnviadoProdutor)
	c.Estado = PACOTE_ENVIADO_PARA_COOPERATIVA
	return s.salvar(ctx, c)
}

func (s *SmartContract) CooperativaConfirmarEntrega(ctx contractapi.TransactionContextInterface, idContrato string, pacote string) error {
	c, _ := s.LerContrato(ctx, idContrato)
	if c.Estado != PACOTE_ENVIADO_PARA_COOPERATIVA { return fmt.Errorf("estado inválido") }

	json.Unmarshal([]byte(pacote), &c.RecebidoCooperativa)
	c.Estado = PACOTE_RECEBIDO_PELA_COOPERATIVA
	return s.salvar(ctx, c)
}

func (s *SmartContract) CooperativaEnviarEscola(ctx contractapi.TransactionContextInterface, idContrato string, idEscola string, pacote string) error {
	c, _ := s.LerContrato(ctx, idContrato)

	var itens []Item
	json.Unmarshal([]byte(pacote), &itens)

	c.PacotesEscolas[idEscola] = itens
	c.EscolasIDs = append(c.EscolasIDs, idEscola)
	c.Estado = ENVIANDO_PACOTES_PARA_ESCOLAS

	return s.salvar(ctx, c)
}

func (s *SmartContract) EscolaConfirmar(ctx contractapi.TransactionContextInterface, idContrato string, idEscola string, pacote string, temSobra bool) error {
	c, _ := s.LerContrato(ctx, idContrato)

	var itens []Item
	json.Unmarshal([]byte(pacote), &itens)

	c.RecebidoEscolas[idEscola] = itens
	c.ConfirmacoesEscolas++

	if c.ConfirmacoesEscolas == len(c.EscolasIDs) && !temSobra {
		c.Estado = TODOS_PACOTES_RECEBIDOS
	}

	return s.salvar(ctx, c)
}

// --- Helpers de Persistência ---

func (s *SmartContract) LerContrato(ctx contractapi.TransactionContextInterface, id string) (*ContratoAgro, error) {
	bytes, err := ctx.GetStub().GetState(id)
	if err != nil || bytes == nil { return nil, fmt.Errorf("não encontrado") }
	var c ContratoAgro
	json.Unmarshal(bytes, &c)
	return &c, nil
}

func (s *SmartContract) salvar(ctx contractapi.TransactionContextInterface, c *ContratoAgro) error {
	bytes, _ := json.Marshal(c)
	return ctx.GetStub().PutState(c.ID, bytes)
}

func main() {
	cc, _ := contractapi.NewChaincode(&SmartContract{})
	cc.Start()
}

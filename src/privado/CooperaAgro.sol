// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract CooperaAgro {

    enum ESTADO_DO_CONTRATO {
        CONTRATO_CRIADO,
        PRODUTOS_OFERTADOS,
        PRODUTOS_COMPRADOS,
        PACOTE_ENVIADO_PARA_COOPERATIVA,
        PACOTE_RECEBIDO_PELA_COOPERATIVA,
        ENVIANDO_PACOTES_PARA_ESCOLAS,
        TODOS_PACOTES_RECEBIDO_PELAS_ESCOLAS
    }

    struct Item {
        uint256 id_produto;
        uint256 qtd;
    }

    ESTADO_DO_CONTRATO public estado_do_contrato = ESTADO_DO_CONTRATO.CONTRATO_CRIADO;
    
    uint256 public id_produtor;
    uint256 public id_cooperativa;
    uint256[] public id_escolas;
    
    Item[] public pacote_ofertado;
    Item[] public pacote_comprado;
    uint256[] public valores; 

    mapping(uint256 => Item[]) public pacotes_escolas;
    mapping(uint256 => bool) public escola_recebeu;
    uint256 public pacotes_escolas_entregues;

    modifier apenasNoEstado(ESTADO_DO_CONTRATO _estado) {
        require(estado_do_contrato == _estado, "Estado invalido");
        _;
    }

    function produtorOfertar(uint256 _id_produtor, Item[] memory _oferta) public apenasNoEstado(ESTADO_DO_CONTRATO.CONTRATO_CRIADO) {
        id_produtor = _id_produtor;
        for (uint i = 0; i < _oferta.length; i++) {
            pacote_ofertado.push(_oferta[i]);
        }
        estado_do_contrato = ESTADO_DO_CONTRATO.PRODUTOS_OFERTADOS;
    }

    function cooperativaComprar(uint256 _id_cooperativa, Item[] memory _compra, uint256[] memory _valores) public apenasNoEstado(ESTADO_DO_CONTRATO.PRODUTOS_OFERTADOS) {
        id_cooperativa = _id_cooperativa;
        for (uint i = 0; i < _compra.length; i++) {
            pacote_comprado.push(_compra[i]);
            valores.push(_valores[i]);
        }
        estado_do_contrato = ESTADO_DO_CONTRATO.PRODUTOS_COMPRADOS;
    }

    function produtorEnviarPacote() public apenasNoEstado(ESTADO_DO_CONTRATO.PRODUTOS_COMPRADOS) {
        estado_do_contrato = ESTADO_DO_CONTRATO.PACOTE_ENVIADO_PARA_COOPERATIVA;
    }

    function cooperativaConfirmarEntrega() public apenasNoEstado(ESTADO_DO_CONTRATO.PACOTE_ENVIADO_PARA_COOPERATIVA) {
        estado_do_contrato = ESTADO_DO_CONTRATO.PACOTE_RECEBIDO_PELA_COOPERATIVA;
    }

    function cooperativaEnviarPacote(uint256 _id_escola, Item[] memory _pacote) public {
        require(
            estado_do_contrato == ESTADO_DO_CONTRATO.PACOTE_RECEBIDO_PELA_COOPERATIVA || 
            estado_do_contrato == ESTADO_DO_CONTRATO.ENVIANDO_PACOTES_PARA_ESCOLAS,
            "Estado invalido"
        );

        // Adiciona à lista de escolas se for nova
        bool existe = false;
        for(uint i=0; i < id_escolas.length; i++) {
            if(id_escolas[i] == _id_escola) { existe = true; break; }
        }
        if(!existe) id_escolas.push(_id_escola);

        // Abate do estoque e registra envio
        for (uint i = 0; i < _pacote.length; i++) {
            bool produtoEncontrado = false;
            for (uint j = 0; j < pacote_comprado.length; j++) {
                if (pacote_comprado[j].id_produto == _pacote[i].id_produto) {
                    require(pacote_comprado[j].qtd >= _pacote[i].qtd, "Qtd insuficiente no estoque");
                    pacote_comprado[j].qtd -= _pacote[i].qtd;
                    produtoEncontrado = true;
                    break;
                }
            }
            require(produtoEncontrado, "Produto nao consta na compra");
            pacotes_escolas[_id_escola].push(_pacote[i]);
        }

        estado_do_contrato = ESTADO_DO_CONTRATO.ENVIANDO_PACOTES_PARA_ESCOLAS;
    }

    function escolaConfirmarEntrega(uint256 _id_escola) public apenasNoEstado(ESTADO_DO_CONTRATO.ENVIANDO_PACOTES_PARA_ESCOLAS) {
        require(!escola_recebeu[_id_escola], "Escola ja confirmou");
        escola_recebeu[_id_escola] = true;
        pacotes_escolas_entregues++;

        // VERIFICAÇÃO DE ESTOQUE VAZIO
        uint256 saldoTotalRestante = 0;
        for (uint i = 0; i < pacote_comprado.length; i++) {
            saldoTotalRestante += pacote_comprado[i].qtd;
        }

        // Condição: Todas confirmaram E não há mais itens disponíveis
        if (pacotes_escolas_entregues == id_escolas.length && saldoTotalRestante == 0) {
            estado_do_contrato = ESTADO_DO_CONTRATO.TODOS_PACOTES_RECEBIDO_PELAS_ESCOLAS;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.31;

contract CooperaAgro {

    enum ESTADO_DO_CONTRATO {
        INEXISTENTE, // 0
        CONTRATO_CRIADO, // 1
        PRODUTOS_OFERTADOS, // 2
        PRODUTOS_COMPRADOS, // 3
        PACOTE_ENVIADO_PARA_COOPERATIVA, // 4
        PACOTE_RECEBIDO_PELA_COOPERATIVA, // 5
        ENVIANDO_PACOTES_PARA_ESCOLAS, // 6
        TODOS_PACOTES_RECEBIDO_PELAS_ESCOLAS // 7
    }

    struct Item {
        uint256 id_produto;
        uint256 qtd;
    }

    // Mappings para suportar múltiplos contratos por ID
    mapping(uint256 => ESTADO_DO_CONTRATO) public estados;
    mapping(uint256 => uint256) public produtores;
    mapping(uint256 => uint256) public cooperativas;
    mapping(uint256 => uint256[]) public escolas_por_contrato;
    
    mapping(uint256 => Item[]) private ofertas;
    mapping(uint256 => Item[]) private compras;
    mapping(uint256 => uint256[]) public valores_por_contrato;

    // Relacionamento: id_contrato => id_escola => Itens
    mapping(uint256 => mapping(uint256 => Item[])) private pacotes_escolas;
    // Relacionamento: id_contrato => id_escola => se recebeu
    mapping(uint256 => mapping(uint256 => bool)) public escola_confirmou;
    
    mapping(uint256 => uint256) public contagem_entregas_escolas;

    // --- Modifiers ---
    modifier apenasNoEstado(uint256 _id_contrato, ESTADO_DO_CONTRATO _estado) {
        require(estados[_id_contrato] == _estado, "Estado invalido para este contrato");
        _;
    }

    // --- Funções Principais ---

    function criarContrato(uint256 _id_contrato) public {
        require(estados[_id_contrato] == ESTADO_DO_CONTRATO.INEXISTENTE, "ID ja existe");
        estados[_id_contrato] = ESTADO_DO_CONTRATO.CONTRATO_CRIADO;
    }

    function produtorOfertar(uint256 _id_contrato, uint256 _id_produtor, Item[] memory _oferta) 
        public 
        apenasNoEstado(_id_contrato, ESTADO_DO_CONTRATO.CONTRATO_CRIADO) 
    {
        produtores[_id_contrato] = _id_produtor;
        for (uint i = 0; i < _oferta.length; i++) {
            ofertas[_id_contrato].push(_oferta[i]);
        }
        estados[_id_contrato] = ESTADO_DO_CONTRATO.PRODUTOS_OFERTADOS;
    }

    function cooperativaComprar(uint256 _id_contrato, uint256 _id_cooperativa, Item[] memory _compra, uint256[] memory _valores) 
        public 
        apenasNoEstado(_id_contrato, ESTADO_DO_CONTRATO.PRODUTOS_OFERTADOS) 
    {
        cooperativas[_id_contrato] = _id_cooperativa;
        valores_por_contrato[_id_contrato] = _valores;
        
        for (uint i = 0; i < _compra.length; i++) {
            compras[_id_contrato].push(_compra[i]);
        }
        estados[_id_contrato] = ESTADO_DO_CONTRATO.PRODUTOS_COMPRADOS;
    }

    function produtorEnviarPacote(uint256 _id_contrato) 
        public 
        apenasNoEstado(_id_contrato, ESTADO_DO_CONTRATO.PRODUTOS_COMPRADOS) 
    {
        estados[_id_contrato] = ESTADO_DO_CONTRATO.PACOTE_ENVIADO_PARA_COOPERATIVA;
    }

    function cooperativaConfirmarEntrega(uint256 _id_contrato) 
        public 
        apenasNoEstado(_id_contrato, ESTADO_DO_CONTRATO.PACOTE_ENVIADO_PARA_COOPERATIVA) 
    {
        estados[_id_contrato] = ESTADO_DO_CONTRATO.PACOTE_RECEBIDO_PELA_COOPERATIVA;
    }

    function cooperativaEnviarPacote(uint256 _id_contrato, uint256 _id_escola, Item[] memory _pacote) 
        public 
    {
        require(
            estados[_id_contrato] == ESTADO_DO_CONTRATO.PACOTE_RECEBIDO_PELA_COOPERATIVA || 
            estados[_id_contrato] == ESTADO_DO_CONTRATO.ENVIANDO_PACOTES_PARA_ESCOLAS,
            "Estado invalido"
        );

        // Registro da escola no contrato
        bool existe = false;
        uint256[] storage esc = escolas_por_contrato[_id_contrato];
        for(uint i=0; i < esc.length; i++) {
            if(esc[i] == _id_escola) { existe = true; break; }
        }
        if(!existe) esc.push(_id_escola);

        // Abate estoque do contrato específico
        Item[] storage estoque = compras[_id_contrato];
        for (uint i = 0; i < _pacote.length; i++) {
            bool achou = false;
            for (uint j = 0; j < estoque.length; j++) {
                if (estoque[j].id_produto == _pacote[i].id_produto) {
                    require(estoque[j].qtd >= _pacote[i].qtd, "Estoque insuficiente");
                    estoque[j].qtd -= _pacote[i].qtd;
                    achou = true;
                    break;
                }
            }
            require(achou, "Produto nao comprado");
            pacotes_escolas[_id_contrato][_id_escola].push(_pacote[i]);
        }
        estados[_id_contrato] = ESTADO_DO_CONTRATO.ENVIANDO_PACOTES_PARA_ESCOLAS;
    }

    function escolaConfirmarEntrega(uint256 _id_contrato, uint256 _id_escola) 
        public 
        apenasNoEstado(_id_contrato, ESTADO_DO_CONTRATO.ENVIANDO_PACOTES_PARA_ESCOLAS) 
    {
        require(!escola_confirmou[_id_contrato][_id_escola], "Ja confirmado");
        escola_confirmou[_id_contrato][_id_escola] = true;
        contagem_entregas_escolas[_id_contrato]++;

        // Validação de estoque zerado para o contrato específico
        uint256 saldoTotal = 0;
        Item[] storage estoque = compras[_id_contrato];
        for (uint i = 0; i < estoque.length; i++) {
            saldoTotal += estoque[i].qtd;
        }

        if (contagem_entregas_escolas[_id_contrato] == escolas_por_contrato[_id_contrato].length && saldoTotal == 0) {
            estados[_id_contrato] = ESTADO_DO_CONTRATO.TODOS_PACOTES_RECEBIDO_PELAS_ESCOLAS;
        }
    }

    // --- Getters ---
    function getOferta(uint256 _id_contrato) public view returns (Item[] memory) { return ofertas[_id_contrato]; }
    function getCompra(uint256 _id_contrato) public view returns (Item[] memory) { return compras[_id_contrato]; }
    function getPacoteEscola(uint256 _id_contrato, uint256 _id_escola) public view returns (Item[] memory) { return pacotes_escolas[_id_contrato][_id_escola]; }
}

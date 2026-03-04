// SPDX-License-Identifier: MIT

pragma solidity ^0.8.31;
// L1: Deploy custou 0,00XX ETH + 1 Ciclo que custou 0,00XX ETH
contract CooperaAgro { 

    enum ESTADO_DO_CONTRATO {
        CONTRATO_CRIADO, // 0
        PRODUTOS_OFERTADOS, // 1
        PRODUTOS_COMPRADOS, // 2
        PACOTE_ENVIADO_PARA_COOPERATIVA, // 3
        PACOTE_RECEBIDO_PELA_COOPERATIVA, // 4
        ENVIANDO_PACOTES_PARA_ESCOLAS, // 5
        TODOS_PACOTES_RECEBIDO_PELAS_ESCOLAS // 6
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
    mapping(uint256 => Item[]) private pacotes_enviados_produtor;
    mapping(uint256 => Item[]) private pacotes_recebidos_cooperativa;

    // Relacionamento: id_contrato => id_escola => Itens
    mapping(uint256 => mapping(uint256 => Item[])) private pacotes_escolas;    
    mapping(uint256 => mapping(uint256 => Item[])) private pacotes_recebidos_por_escolas;
    mapping(uint256 => uint256) public escolas_que_confirmaram;

    // --- Modifiers ---
    modifier apenasNoEstado(uint256 _id_contrato, ESTADO_DO_CONTRATO _estado) {
        require(estados[_id_contrato] == _estado, "Estado invalido para este contrato");
        _;
    }

    // --- Funções Principais ---

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

    function produtorEnviarPacote(uint256 _id_contrato, Item[] memory _pacote) 
        public 
        apenasNoEstado(_id_contrato, ESTADO_DO_CONTRATO.PRODUTOS_COMPRADOS) 
    {
        for (uint i = 0; i < _pacote.length; i++) {
            pacotes_enviados_produtor[_id_contrato].push(_pacote[i]);
        }
        estados[_id_contrato] = ESTADO_DO_CONTRATO.PACOTE_ENVIADO_PARA_COOPERATIVA;
    }

    function cooperativaConfirmarEntrega(uint256 _id_contrato, Item[] memory _pacote) 
        public 
        apenasNoEstado(_id_contrato, ESTADO_DO_CONTRATO.PRODUTOS_COMPRADOS) 
    {
        for (uint i = 0; i < _pacote.length; i++) {
            pacotes_recebidos_cooperativa[_id_contrato].push(_pacote[i]);
        }
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
        escolas_por_contrato[_id_contrato].push(_id_escola);

        for (uint i = 0; i < _pacote.length; i++) {
            pacotes_escolas[_id_contrato][_id_escola].push(_pacote[i]);
        }

        if (estados[_id_contrato] == ESTADO_DO_CONTRATO.ENVIANDO_PACOTES_PARA_ESCOLAS) {
            estados[_id_contrato] = ESTADO_DO_CONTRATO.ENVIANDO_PACOTES_PARA_ESCOLAS;
        }
    }

    function escolaConfirmarEntrega(uint256 _id_contrato, uint256 _id_escola, Item[] memory _pacote, bool _tem_sobra_no_estoque) 
        public 
        apenasNoEstado(_id_contrato, ESTADO_DO_CONTRATO.ENVIANDO_PACOTES_PARA_ESCOLAS) 
    {
        for (uint i = 0; i < _pacote.length; i++) {
            pacotes_recebidos_por_escolas[_id_contrato][_id_escola].push(_pacote[i]);
        }
        escolas_que_confirmaram[_id_contrato] ++;

        // Validação de estoque zerado para o contrato específico
        if ( (escolas_que_confirmaram[_id_contrato] == escolas_por_contrato[_id_contrato].length) && !_tem_sobra_no_estoque) {
            estados[_id_contrato] = ESTADO_DO_CONTRATO.TODOS_PACOTES_RECEBIDO_PELAS_ESCOLAS;
        }
    }

    // --- Getters ---
    function getOferta(uint256 _id_contrato) public view returns (Item[] memory) { return ofertas[_id_contrato]; }
    function getCompra(uint256 _id_contrato) public view returns (Item[] memory) { return compras[_id_contrato]; }
    function getPacoteEscola(uint256 _id_contrato, uint256 _id_escola) public view returns (Item[] memory) { return pacotes_escolas[_id_contrato][_id_escola]; }
}

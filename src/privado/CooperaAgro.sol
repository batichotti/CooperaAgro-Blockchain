// SPDX-License-Identifier: MIT

pragma solidity ^0.8.31;

/*
Produtor oferta os itens ->
10 x Cenouras
40 x Batatas
20 x Repolhos

Cooperativa fala o tanto que quer e q valor vai pagar ->
5 x Cenouras (R$ 3,00 unidade (300 normalizado para o código))
30 x Batatas (R$ 2,00 unidade (200 normalizado para o código))
7 x Repolhos (R$ 2,75 unidade (275 normalizado para o código))

Cooperativa compra

Pordutor manda os itens e fica com o resto q a coperativa n comprou

Cooperativa recebe

Cooperativa manda para escolas
Escola Capo Alegre
1 x Cenouras
15 x Batatas
3 x Repolhos
Escola Sorridente
2 x Cenouras
7 x Batatas
2 x Repolhos
Escola Arcoires Fantastico

Cada escolas confirmam recebimento
5 x Cenouras
30 x Batatas
7 x Repolhos
*/

contract CooperaAgro {

    // Progresso do contrato ==========================
    enum ESTADO_DO_CONTRATO {
        CONTRATO_CRIADO,
        PRODUTOS_OFERTADOS,
        PRODUTOS_COMPRADOS,
        PACOTE_ENVIADO_PARA_COOPERATIVA,
        PACOTE_RECEBIDO_PELA_COOPERATIVA,
        ENVIANDO_PACOTES_PARA_ESCOLAS,
        TODOS_PACOTES_RECEBIDO_PELAS_ESCOLAS
    }

    // Produtos ===================================
    struct Item {
        uint256 id_produto;
        uint256 qtd;
    }


    // Variáveis de controle ==============================================
    // id_contrato; -> vem do backend

    ESTADO_DO_CONTRATO estado_do_contrato = ESTADO_DO_CONTRATO.CONTRATO_CRIADO;
    
    uint256 id_produtor;
    uint256 id_cooperativa;
    uint256[] id_escolas;
    uint256 qtd_escolas;

    Item[] pacote_ofertado;

    Item[] pacote_comprado;
    bool is_itens_comprados_disponiveis = false;
    uint256[] valores; // relação idx de itens no pacote_comprado com o seu valor

    mapping(uint256 => Item[]) pacotes_escolas; // relação id da escola com seu pacote
    uint256 pacotes_escolas_entregues;


    // Requisitos Funcionais ===============================================
    
    /*
        @dev Produtor define quais e quantos produtos serão ofertados
    */
    function produtorOfertar(uint256 _id_produtor, Item memory _oferta) public {
        // if(estado_do_contrato != CONTRATO_CRIADO) return
        // id_produtor = _id_produtor;
        // pacote_ofertado.itens = _oferta;
        // atualizar estado
    }

    /*
        @dev Cooperativa escolhe quais e quantos produtos vai comprar e qual valor de cada produto
    */
    function cooperativaComprar(uint256 _id_cooperativa, Item memory _compra, uint256[] memory _valores) public {
        // if(estado_do_contrato != PRODUTOS_OFERTADOS) return
        // id_cooperativa = _id_cooperativa;
        // pacote_ofertado.itens = _oferta;
        // valores = _valores;
        // atualizar estado
    }

    /*
        @dev Produtor envia o pacote com os itens requisitados
    */
    function produtorEnviarPacote() public {
        // if(estado_do_contrato != PRODUTOS_COMPRADOS) return
        // atualizar estado 
    }

    /*
        @dev Cooperativa confirma q recebeu o pacote e atualiza q tem itens disponiveis para entregar
    */
    function cooperativaConfirmarEntrega() public {
        // if(estado_do_contrato != PACOTE_ENVIADO_PARA_COOPERATIVA) return
        // itens_comprados_disponiveis = true
        // atualizar estado
    }

    /*
        @dev Cooperativa manda um pacote para cada escola enquanto houver itens disponiveis,
        soma o contador de escolas, quando acabar todos itens disponivei atualiza a tag
    */
    function cooperativaEnviarPacote(uint256 _id_escola, Item memory _pacote) public {
        // if(estado_do_contrato != PACOTE_ENVIADO_PARA_COOPERATIVA || estado_do_contrato != ENVIANDO_PACOTES_PARA_ESCOLAS) return

        /*
        temp
        for item in pacote_comprados
            temp += qtd
        
        if (temp > 0)
            pacotes_escolas[_id_escola] = _pacote
            qtd_escolas++;
            if (estado_do_contrato != ENVIANDO_PACOTES_PARA_ESCOLAS)
            atualizar estadp
        */
    }

    /*
        @dev Escola confirma o pecebimento dos produtos, aumenta o contador de escolas q receberam o pacote,
        quando o contador de escolas q receberam os pacotes for igual ao contador de escolas cadastradas
        e quando acabar os itens em estoque finalizar o contrato atualizando para TODOS_PACOTES_RECEBIDO_PELAS_ESCOLAS
    */
    function escolaConfirmarEntrega(uint256 _id_escola) public {
    // if (qtd_escolas = ++pacotes_escolas_entregues && !is_itens_comprados_disponiveis) {
        // if(estado_do_contrato != ENVIANDO_PACOTES_PARA_ESCOLAS) return
        atualizar estado finalizar contrato
    }
    }

    // Getters ===============================================

    function getEstadoContrato() public view returns(ESTADO_DO_CONTRATO){
        return estado_do_contrato;
    }

    function getIdProdutor() public view returns(uint256){
        return id_produtor;
    }

    function getIdCooperativa() public view returns(uint256){
        return id_cooperativa;
    }

    function getIdEscolas() public view returns(uint256[] memory){
        return id_escolas;
    }
    
    function getIdEscola(uint256 _pos) public view returns(uint256){
        return id_escolas[_pos];
    }

    function getPacoteOfertado() public view returns (Item[] memory) {
        return pacote_ofertado;
    }
    
    function getPacoteComprado() public view returns (Item[] memory) {
        return pacote_comprado;
    }

    function getPacotesEscolas(uint256 _id_escola) public view returns (Item[] memory) {
        return pacotes_escolas[_id_escola];
    }

    function getPacotesEscolasEntregues() public view returns (uint256) {
        return pacotes_escolas_entregues;
    }

}

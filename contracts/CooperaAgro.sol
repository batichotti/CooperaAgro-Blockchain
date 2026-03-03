// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CooperaAgro {
    
    struct Produtor {
        uint256 id;
        string nome;
        string cpfCnpj;
        string localizacao;
        bool ativo;
        uint256 dataRegistro;
    }
    
    struct Lote {
        uint256 id;
        uint256 produtorId;
        string nomeProduto;
        uint8 tipoProduto;
        uint256 quantidade;
        uint256 dataPlantio;
        uint256 dataColheita;
        uint8 status;
        string localizacao;
        bool organico;
    }
    
    struct DadosPlantio {
        string cultivar;
        string metodoCultivo;
        string[] insumos;
        string coordenadasGPS;
    }
    
    struct DadosCultivo {
        string[] tratamentos;
        string[] fertilizantes;
        uint256 consumoAgua;
        string manejo;
    }
    
    struct DadosColheita {
        uint256 data;
        uint256 quantidade;
        string metodologia;
        string qualidade;
    }
    
    struct DadosProcessamento {
        uint256 data;
        string tipo;
        string[] etapas;
        uint256 quantidadeFinal;
        string embalagem;
    }
    
    struct Certificacao {
        string tipo;
        string orgao;
        string numero;
        uint256 validade;
        string documentoHash;
    }
    
    uint256 public proximoLoteId;
    uint256 public proximoProdutorId;
    
    mapping(uint256 => Produtor) public produtores;
    mapping(uint256 => Lote) public lotes;
    mapping(uint256 => DadosPlantio) public plantios;
    mapping(uint256 => DadosCultivo) public cultivos;
    mapping(uint256 => DadosColheita) public colheitas;
    mapping(uint256 => DadosProcessamento) public processamentos;
    mapping(uint256 => Certificacao[]) public certificacoes;
    
    uint256[] public listaProdutores;
    uint256[] public listaLotes;
    
    event ProdutorRegistrado(uint256 indexed produtorId, uint256 timestamp);
    event LoteCriado(uint256 indexed loteId, uint256 indexed produtorId, uint256 timestamp);
    event ColheitaRegistrada(uint256 indexed loteId, uint256 quantidade);
    event StatusAtualizado(uint256 indexed loteId, uint8 status);
    
    function registrarProdutor(
        string memory _nome,
        string memory _cpfCnpj,
        string memory _localizacao
    ) external returns (uint256) {
        uint256 produtorId = proximoProdutorId++;
        
        produtores[produtorId] = Produtor({
            id: produtorId,
            nome: _nome,
            cpfCnpj: _cpfCnpj,
            localizacao: _localizacao,
            ativo: true,
            dataRegistro: block.timestamp
        });
        
        listaProdutores.push(produtorId);
        emit ProdutorRegistrado(produtorId, block.timestamp);
        
        return produtorId;
    }
    
    function criarLote(
        uint256 _produtorId,
        string memory _nomeProduto,
        uint8 _tipoProduto,
        uint256 _quantidade,
        uint256 _dataPlantio,
        string memory _localizacao,
        bool _organico
    ) external returns (uint256) {
        require(produtores[_produtorId].ativo);
        
        uint256 loteId = proximoLoteId++;
        
        lotes[loteId] = Lote({
            id: loteId,
            produtorId: _produtorId,
            nomeProduto: _nomeProduto,
            tipoProduto: _tipoProduto,
            quantidade: _quantidade,
            dataPlantio: _dataPlantio,
            dataColheita: 0,
            status: 0,
            localizacao: _localizacao,
            organico: _organico
        });
        
        listaLotes.push(loteId);
        emit LoteCriado(loteId, _produtorId, block.timestamp);
        
        return loteId;
    }
    
    function registrarPlantio(
        uint256 _loteId,
        string memory _cultivar,
        string memory _metodoCultivo,
        string[] memory _insumos,
        string memory _coordenadasGPS
    ) external {
        require(_loteId < proximoLoteId);
        
        plantios[_loteId] = DadosPlantio({
            cultivar: _cultivar,
            metodoCultivo: _metodoCultivo,
            insumos: _insumos,
            coordenadasGPS: _coordenadasGPS
        });
    }
    
    function registrarCultivo(
        uint256 _loteId,
        string[] memory _tratamentos,
        string[] memory _fertilizantes,
        uint256 _consumoAgua,
        string memory _manejo
    ) external {
        require(_loteId < proximoLoteId);
        
        cultivos[_loteId] = DadosCultivo({
            tratamentos: _tratamentos,
            fertilizantes: _fertilizantes,
            consumoAgua: _consumoAgua,
            manejo: _manejo
        });
        
        lotes[_loteId].status = 1;
        emit StatusAtualizado(_loteId, 1);
    }
    
    function registrarColheita(
        uint256 _loteId,
        uint256 _quantidade,
        string memory _metodologia,
        string memory _qualidade
    ) external {
        require(_loteId < proximoLoteId);
        
        colheitas[_loteId] = DadosColheita({
            data: block.timestamp,
            quantidade: _quantidade,
            metodologia: _metodologia,
            qualidade: _qualidade
        });
        
        lotes[_loteId].dataColheita = block.timestamp;
        lotes[_loteId].quantidade = _quantidade;
        lotes[_loteId].status = 2;
        
        emit ColheitaRegistrada(_loteId, _quantidade);
        emit StatusAtualizado(_loteId, 2);
    }
    
    function registrarProcessamento(
        uint256 _loteId,
        string memory _tipo,
        string[] memory _etapas,
        uint256 _quantidadeFinal,
        string memory _embalagem
    ) external {
        require(_loteId < proximoLoteId);
        
        processamentos[_loteId] = DadosProcessamento({
            data: block.timestamp,
            tipo: _tipo,
            etapas: _etapas,
            quantidadeFinal: _quantidadeFinal,
            embalagem: _embalagem
        });
        
        lotes[_loteId].quantidade = _quantidadeFinal;
        lotes[_loteId].status = 4;
        emit StatusAtualizado(_loteId, 4);
    }
    
    function adicionarCertificacao(
        uint256 _loteId,
        string memory _tipo,
        string memory _orgao,
        string memory _numero,
        uint256 _validade,
        string memory _documentoHash
    ) external {
        require(_loteId < proximoLoteId);
        
        certificacoes[_loteId].push(Certificacao({
            tipo: _tipo,
            orgao: _orgao,
            numero: _numero,
            validade: _validade,
            documentoHash: _documentoHash
        }));
    }
    
    function obterRastreabilidade(uint256 _loteId) external view returns (
        Lote memory lote,
        Produtor memory produtor,
        DadosPlantio memory plantio,
        DadosCultivo memory cultivo,
        DadosColheita memory colheita,
        DadosProcessamento memory processamento
    ) {
        require(_loteId < proximoLoteId);
        
        lote = lotes[_loteId];
        produtor = produtores[lote.produtorId];
        plantio = plantios[_loteId];
        cultivo = cultivos[_loteId];
        colheita = colheitas[_loteId];
        processamento = processamentos[_loteId];
        
        return (lote, produtor, plantio, cultivo, colheita, processamento);
    }
    
    function obterCertificacoes(uint256 _loteId) external view returns (Certificacao[] memory) {
        require(_loteId < proximoLoteId);
        return certificacoes[_loteId];
    }
    
    function obterLotesPorProdutor(uint256 _produtorId) external view returns (uint256[] memory) {
        uint256 count;
        for (uint256 i; i < proximoLoteId; i++) {
            if (lotes[i].produtorId == _produtorId) count++;
        }
        
        uint256[] memory lotesProdutor = new uint256[](count);
        uint256 index;
        for (uint256 i; i < proximoLoteId; i++) {
            if (lotes[i].produtorId == _produtorId) {
                lotesProdutor[index++] = i;
            }
        }
        
        return lotesProdutor;
    }
    
    function obterTodosLotes() external view returns (uint256[] memory) {
        return listaLotes;
    }
    
    function obterTodosProdutores() external view returns (uint256[] memory) {
        return listaProdutores;
    }
    
    function verificarOrganico(uint256 _loteId) external view returns (bool) {
        require(_loteId < proximoLoteId);
        return lotes[_loteId].organico;
    }
    
    function atualizarStatus(uint256 _loteId, uint8 _status) external {
        require(_loteId < proximoLoteId);
        lotes[_loteId].status = _status;
        emit StatusAtualizado(_loteId, _status);
    }
    
    function desativarProdutor(uint256 _produtorId) external {
        produtores[_produtorId].ativo = false;
    }
}
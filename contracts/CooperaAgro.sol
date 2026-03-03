// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CooperaAgro - Sistema de Rastreabilidade Agrícola
 * @notice Contrato para rastrear toda a cadeia produtiva de produtos agrícolas
 * @dev Implementa rastreabilidade completa desde o plantio até o consumidor final
 */
contract CooperaAgro {
    
    // ========== ESTRUTURAS DE DADOS ==========
    
    struct Produtor {
        address endereco;
        string nome;
        string cpfCnpj;
        string localizacao;
        string certificacoes;
        bool ativo;
        uint256 dataRegistro;
    }
    
    struct Lote {
        uint256 id;
        address produtor;
        string nomeProduto;
        TipoProduto tipoProduto;
        uint256 quantidade; // em kg
        uint256 dataPlantio;
        uint256 dataColheita;
        StatusLote status;
        string localizacaoFazenda;
        bool certificadoOrganico;
    }
    
    struct ProcessoPlantio {
        uint256 loteId;
        string cultivar;
        string metodoCultivo;
        string tipoSolo;
        string[] insumos;
        string sistemaIrrigacao;
        uint256 dataPlantio;
        string coordenadasGPS;
    }
    
    struct ProcessoCultivo {
        uint256 loteId;
        string[] tratamentosFitossanitarios;
        string[] fertilizantes;
        string[] pesticidas; // vazio se orgânico
        uint256[] datasAplicacao;
        string manejoSustentavel;
        uint256 consumoAgua; // em litros
    }
    
    struct ProcessoColheita {
        uint256 loteId;
        uint256 dataColheita;
        uint256 quantidadeColhida; // em kg
        string metodologiaColheita;
        string condicoesClimaticas;
        string qualidadeAvaliada;
    }
    
    struct ProcessamentoIndustrial {
        uint256 loteId;
        uint256 dataProcessamento;
        string tipoProcessamento;
        string[] etapasProcessamento;
        string controleQualidade;
        string[] laudosLaboratoriais;
        uint256 quantidadeFinal; // em kg após processamento
        string embalagem;
    }
    
    struct Transporte {
        uint256 loteId;
        address transportadora;
        string nomeTransportadora;
        uint256 dataInicio;
        uint256 dataChegada;
        string origem;
        string destino;
        string condicoesTransporte;
        string temperaturaControle;
    }
    
    struct Distribuicao {
        uint256 loteId;
        address distribuidor;
        string nomeDistribuidor;
        uint256 dataDistribuicao;
        string localDestino;
        string tipoEstabelecimento; // supermercado, feira, etc
    }
    
    struct Certificacao {
        uint256 loteId;
        string tipoCertificacao; // Orgânico, Fair Trade, etc
        string orgaoCertificador;
        string numeroCertificado;
        uint256 dataEmissao;
        uint256 dataValidade;
        string documentoHash; // IPFS hash do documento
    }
    
    struct Auditoria {
        uint256 loteId;
        address auditor;
        string nomeAuditor;
        uint256 dataAuditoria;
        string resultado;
        string observacoes;
        bool aprovado;
    }
    
    // ========== ENUMS ==========
    
    enum TipoProduto {
        Graos,
        Hortalicas,
        Frutas,
        Cafe,
        CanaDeAcucar,
        Outros
    }
    
    enum StatusLote {
        Plantado,
        EmCultivo,
        Colhido,
        EmProcessamento,
        Processado,
        EmTransporte,
        Distribuido,
        Vendido
    }
    
    enum TipoUsuario {
        Admin,
        Produtor,
        Processador,
        Transportador,
        Distribuidor,
        Auditor,
        Consumidor
    }
    
    // ========== VARIÁVEIS DE ESTADO ==========
    
    address public owner;
    uint256 public proximoLoteId;
    
    mapping(address => Produtor) public produtores;
    mapping(address => TipoUsuario) public tiposUsuario;
    mapping(uint256 => Lote) public lotes;
    mapping(uint256 => ProcessoPlantio) public processosPlantio;
    mapping(uint256 => ProcessoCultivo) public processosCultivo;
    mapping(uint256 => ProcessoColheita) public processosColheita;
    mapping(uint256 => ProcessamentoIndustrial) public processamentosIndustriais;
    mapping(uint256 => Transporte[]) public transportes;
    mapping(uint256 => Distribuicao[]) public distribuicoes;
    mapping(uint256 => Certificacao[]) public certificacoes;
    mapping(uint256 => Auditoria[]) public auditorias;
    
    address[] public listaProdutores;
    uint256[] public listaLotes;
    
    // ========== EVENTOS ==========
    
    event ProdutorRegistrado(address indexed produtor, string nome, uint256 timestamp);
    event LoteCriado(uint256 indexed loteId, address indexed produtor, string nomeProduto, uint256 timestamp);
    event PlantioRegistrado(uint256 indexed loteId, uint256 timestamp);
    event CultivoRegistrado(uint256 indexed loteId, uint256 timestamp);
    event ColheitaRegistrada(uint256 indexed loteId, uint256 quantidadeColhida, uint256 timestamp);
    event ProcessamentoRegistrado(uint256 indexed loteId, string tipoProcessamento, uint256 timestamp);
    event TransporteRegistrado(uint256 indexed loteId, string destino, uint256 timestamp);
    event DistribuicaoRegistrada(uint256 indexed loteId, string localDestino, uint256 timestamp);
    event CertificacaoAdicionada(uint256 indexed loteId, string tipoCertificacao, uint256 timestamp);
    event AuditoriaRealizada(uint256 indexed loteId, address auditor, bool aprovado, uint256 timestamp);
    event StatusLoteAtualizado(uint256 indexed loteId, StatusLote novoStatus, uint256 timestamp);
    
    // ========== MODIFICADORES ==========
    
    modifier apenasOwner() {
        require(msg.sender == owner, "Apenas o proprietario pode executar");
        _;
    }
    
    modifier apenasProdutor() {
        require(tiposUsuario[msg.sender] == TipoUsuario.Produtor || msg.sender == owner, "Apenas produtores autorizados");
        require(produtores[msg.sender].ativo, "Produtor nao esta ativo");
        _;
    }
    
    modifier apenasProcessador() {
        require(tiposUsuario[msg.sender] == TipoUsuario.Processador || msg.sender == owner, "Apenas processadores autorizados");
        _;
    }
    
    modifier apenasTransportador() {
        require(tiposUsuario[msg.sender] == TipoUsuario.Transportador || msg.sender == owner, "Apenas transportadores autorizados");
        _;
    }
    
    modifier apenasDistribuidor() {
        require(tiposUsuario[msg.sender] == TipoUsuario.Distribuidor || msg.sender == owner, "Apenas distribuidores autorizados");
        _;
    }
    
    modifier apenasAuditor() {
        require(tiposUsuario[msg.sender] == TipoUsuario.Auditor || msg.sender == owner, "Apenas auditores autorizados");
        _;
    }
    
    modifier loteExiste(uint256 _loteId) {
        require(_loteId < proximoLoteId, "Lote nao existe");
        _;
    }
    
    // ========== CONSTRUCTOR ==========
    
    constructor() {
        owner = msg.sender;
        tiposUsuario[msg.sender] = TipoUsuario.Admin;
        proximoLoteId = 0;
    }
    
    // ========== FUNÇÕES DE GERENCIAMENTO DE USUÁRIOS ==========
    
    function registrarProdutor(
        address _endereco,
        string memory _nome,
        string memory _cpfCnpj,
        string memory _localizacao,
        string memory _certificacoes
    ) external apenasOwner {
        require(_endereco != address(0), "Endereco invalido");
        require(!produtores[_endereco].ativo, "Produtor ja registrado");
        
        produtores[_endereco] = Produtor({
            endereco: _endereco,
            nome: _nome,
            cpfCnpj: _cpfCnpj,
            localizacao: _localizacao,
            certificacoes: _certificacoes,
            ativo: true,
            dataRegistro: block.timestamp
        });
        
        tiposUsuario[_endereco] = TipoUsuario.Produtor;
        listaProdutores.push(_endereco);
        
        emit ProdutorRegistrado(_endereco, _nome, block.timestamp);
    }
    
    function definirTipoUsuario(address _usuario, TipoUsuario _tipo) external apenasOwner {
        require(_usuario != address(0), "Endereco invalido");
        tiposUsuario[_usuario] = _tipo;
    }
    
    function desativarProdutor(address _endereco) external apenasOwner {
        require(produtores[_endereco].ativo, "Produtor ja inativo");
        produtores[_endereco].ativo = false;
    }
    
    // ========== FUNÇÕES DE CRIAÇÃO E REGISTRO ==========
    
    function criarLote(
        string memory _nomeProduto,
        TipoProduto _tipoProduto,
        uint256 _quantidade,
        uint256 _dataPlantio,
        string memory _localizacaoFazenda,
        bool _certificadoOrganico
    ) external apenasProdutor returns (uint256) {
        uint256 loteId = proximoLoteId;
        proximoLoteId++;
        
        lotes[loteId] = Lote({
            id: loteId,
            produtor: msg.sender,
            nomeProduto: _nomeProduto,
            tipoProduto: _tipoProduto,
            quantidade: _quantidade,
            dataPlantio: _dataPlantio,
            dataColheita: 0,
            status: StatusLote.Plantado,
            localizacaoFazenda: _localizacaoFazenda,
            certificadoOrganico: _certificadoOrganico
        });
        
        listaLotes.push(loteId);
        
        emit LoteCriado(loteId, msg.sender, _nomeProduto, block.timestamp);
        
        return loteId;
    }
    
    function registrarPlantio(
        uint256 _loteId,
        string memory _cultivar,
        string memory _metodoCultivo,
        string memory _tipoSolo,
        string[] memory _insumos,
        string memory _sistemaIrrigacao,
        string memory _coordenadasGPS
    ) external apenasProdutor loteExiste(_loteId) {
        require(lotes[_loteId].produtor == msg.sender, "Apenas o produtor do lote pode registrar");
        
        processosPlantio[_loteId] = ProcessoPlantio({
            loteId: _loteId,
            cultivar: _cultivar,
            metodoCultivo: _metodoCultivo,
            tipoSolo: _tipoSolo,
            insumos: _insumos,
            sistemaIrrigacao: _sistemaIrrigacao,
            dataPlantio: lotes[_loteId].dataPlantio,
            coordenadasGPS: _coordenadasGPS
        });
        
        emit PlantioRegistrado(_loteId, block.timestamp);
    }
    
    function registrarCultivo(
        uint256 _loteId,
        string[] memory _tratamentosFitossanitarios,
        string[] memory _fertilizantes,
        string[] memory _pesticidas,
        uint256[] memory _datasAplicacao,
        string memory _manejoSustentavel,
        uint256 _consumoAgua
    ) external apenasProdutor loteExiste(_loteId) {
        require(lotes[_loteId].produtor == msg.sender, "Apenas o produtor do lote pode registrar");
        
        if (lotes[_loteId].certificadoOrganico) {
            require(_pesticidas.length == 0, "Produtos organicos nao podem usar pesticidas sinteticos");
        }
        
        processosCultivo[_loteId] = ProcessoCultivo({
            loteId: _loteId,
            tratamentosFitossanitarios: _tratamentosFitossanitarios,
            fertilizantes: _fertilizantes,
            pesticidas: _pesticidas,
            datasAplicacao: _datasAplicacao,
            manejoSustentavel: _manejoSustentavel,
            consumoAgua: _consumoAgua
        });
        
        lotes[_loteId].status = StatusLote.EmCultivo;
        
        emit CultivoRegistrado(_loteId, block.timestamp);
        emit StatusLoteAtualizado(_loteId, StatusLote.EmCultivo, block.timestamp);
    }
    
    function registrarColheita(
        uint256 _loteId,
        uint256 _quantidadeColhida,
        string memory _metodologiaColheita,
        string memory _condicoesClimaticas,
        string memory _qualidadeAvaliada
    ) external apenasProdutor loteExiste(_loteId) {
        require(lotes[_loteId].produtor == msg.sender, "Apenas o produtor do lote pode registrar");
        require(lotes[_loteId].status == StatusLote.EmCultivo || lotes[_loteId].status == StatusLote.Plantado, "Status invalido para colheita");
        
        processosColheita[_loteId] = ProcessoColheita({
            loteId: _loteId,
            dataColheita: block.timestamp,
            quantidadeColhida: _quantidadeColhida,
            metodologiaColheita: _metodologiaColheita,
            condicoesClimaticas: _condicoesClimaticas,
            qualidadeAvaliada: _qualidadeAvaliada
        });
        
        lotes[_loteId].dataColheita = block.timestamp;
        lotes[_loteId].quantidade = _quantidadeColhida;
        lotes[_loteId].status = StatusLote.Colhido;
        
        emit ColheitaRegistrada(_loteId, _quantidadeColhida, block.timestamp);
        emit StatusLoteAtualizado(_loteId, StatusLote.Colhido, block.timestamp);
    }
    
    function registrarProcessamento(
        uint256 _loteId,
        string memory _tipoProcessamento,
        string[] memory _etapasProcessamento,
        string memory _controleQualidade,
        string[] memory _laudosLaboratoriais,
        uint256 _quantidadeFinal,
        string memory _embalagem
    ) external apenasProcessador loteExiste(_loteId) {
        require(lotes[_loteId].status == StatusLote.Colhido || lotes[_loteId].status == StatusLote.EmProcessamento, "Status invalido para processamento");
        
        processamentosIndustriais[_loteId] = ProcessamentoIndustrial({
            loteId: _loteId,
            dataProcessamento: block.timestamp,
            tipoProcessamento: _tipoProcessamento,
            etapasProcessamento: _etapasProcessamento,
            controleQualidade: _controleQualidade,
            laudosLaboratoriais: _laudosLaboratoriais,
            quantidadeFinal: _quantidadeFinal,
            embalagem: _embalagem
        });
        
        lotes[_loteId].quantidade = _quantidadeFinal;
        lotes[_loteId].status = StatusLote.Processado;
        
        emit ProcessamentoRegistrado(_loteId, _tipoProcessamento, block.timestamp);
        emit StatusLoteAtualizado(_loteId, StatusLote.Processado, block.timestamp);
    }
    
    function registrarTransporte(
        uint256 _loteId,
        address _transportadora,
        string memory _nomeTransportadora,
        uint256 _dataChegada,
        string memory _origem,
        string memory _destino,
        string memory _condicoesTransporte,
        string memory _temperaturaControle
    ) external apenasTransportador loteExiste(_loteId) {
        transportes[_loteId].push(Transporte({
            loteId: _loteId,
            transportadora: _transportadora,
            nomeTransportadora: _nomeTransportadora,
            dataInicio: block.timestamp,
            dataChegada: _dataChegada,
            origem: _origem,
            destino: _destino,
            condicoesTransporte: _condicoesTransporte,
            temperaturaControle: _temperaturaControle
        }));
        
        lotes[_loteId].status = StatusLote.EmTransporte;
        
        emit TransporteRegistrado(_loteId, _destino, block.timestamp);
        emit StatusLoteAtualizado(_loteId, StatusLote.EmTransporte, block.timestamp);
    }
    
    function registrarDistribuicao(
        uint256 _loteId,
        address _distribuidor,
        string memory _nomeDistribuidor,
        string memory _localDestino,
        string memory _tipoEstabelecimento
    ) external apenasDistribuidor loteExiste(_loteId) {
        distribuicoes[_loteId].push(Distribuicao({
            loteId: _loteId,
            distribuidor: _distribuidor,
            nomeDistribuidor: _nomeDistribuidor,
            dataDistribuicao: block.timestamp,
            localDestino: _localDestino,
            tipoEstabelecimento: _tipoEstabelecimento
        }));
        
        lotes[_loteId].status = StatusLote.Distribuido;
        
        emit DistribuicaoRegistrada(_loteId, _localDestino, block.timestamp);
        emit StatusLoteAtualizado(_loteId, StatusLote.Distribuido, block.timestamp);
    }
    
    // ========== FUNÇÕES DE CERTIFICAÇÃO E AUDITORIA ==========
    
    function adicionarCertificacao(
        uint256 _loteId,
        string memory _tipoCertificacao,
        string memory _orgaoCertificador,
        string memory _numeroCertificado,
        uint256 _dataValidade,
        string memory _documentoHash
    ) external apenasAuditor loteExiste(_loteId) {
        certificacoes[_loteId].push(Certificacao({
            loteId: _loteId,
            tipoCertificacao: _tipoCertificacao,
            orgaoCertificador: _orgaoCertificador,
            numeroCertificado: _numeroCertificado,
            dataEmissao: block.timestamp,
            dataValidade: _dataValidade,
            documentoHash: _documentoHash
        }));
        
        emit CertificacaoAdicionada(_loteId, _tipoCertificacao, block.timestamp);
    }
    
    function realizarAuditoria(
        uint256 _loteId,
        string memory _nomeAuditor,
        string memory _resultado,
        string memory _observacoes,
        bool _aprovado
    ) external apenasAuditor loteExiste(_loteId) {
        auditorias[_loteId].push(Auditoria({
            loteId: _loteId,
            auditor: msg.sender,
            nomeAuditor: _nomeAuditor,
            dataAuditoria: block.timestamp,
            resultado: _resultado,
            observacoes: _observacoes,
            aprovado: _aprovado
        }));
        
        emit AuditoriaRealizada(_loteId, msg.sender, _aprovado, block.timestamp);
    }
    
    // ========== FUNÇÕES DE CONSULTA ==========
    
    function obterRastreabilidadeCompleta(uint256 _loteId) external view loteExiste(_loteId) returns (
        Lote memory lote,
        Produtor memory produtor,
        ProcessoPlantio memory plantio,
        ProcessoCultivo memory cultivo,
        ProcessoColheita memory colheita,
        ProcessamentoIndustrial memory processamento
    ) {
        lote = lotes[_loteId];
        produtor = produtores[lote.produtor];
        plantio = processosPlantio[_loteId];
        cultivo = processosCultivo[_loteId];
        colheita = processosColheita[_loteId];
        processamento = processamentosIndustriais[_loteId];
        
        return (lote, produtor, plantio, cultivo, colheita, processamento);
    }
    
    function obterTransportes(uint256 _loteId) external view loteExiste(_loteId) returns (Transporte[] memory) {
        return transportes[_loteId];
    }
    
    function obterDistribuicoes(uint256 _loteId) external view loteExiste(_loteId) returns (Distribuicao[] memory) {
        return distribuicoes[_loteId];
    }
    
    function obterCertificacoes(uint256 _loteId) external view loteExiste(_loteId) returns (Certificacao[] memory) {
        return certificacoes[_loteId];
    }
    
    function obterAuditorias(uint256 _loteId) external view loteExiste(_loteId) returns (Auditoria[] memory) {
        return auditorias[_loteId];
    }
    
    function obterLotesPorProdutor(address _produtor) external view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < proximoLoteId; i++) {
            if (lotes[i].produtor == _produtor) {
                count++;
            }
        }
        
        uint256[] memory lotesProdutor = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < proximoLoteId; i++) {
            if (lotes[i].produtor == _produtor) {
                lotesProdutor[index] = i;
                index++;
            }
        }
        
        return lotesProdutor;
    }
    
    function obterTodosOsLotes() external view returns (uint256[] memory) {
        return listaLotes;
    }
    
    function obterTodosOsProdutores() external view returns (address[] memory) {
        return listaProdutores;
    }
    
    function verificarCertificadoOrganico(uint256 _loteId) external view loteExiste(_loteId) returns (bool) {
        return lotes[_loteId].certificadoOrganico;
    }
    
    // ========== FUNÇÕES ADMINISTRATIVAS ==========
    
    function atualizarStatusLote(uint256 _loteId, StatusLote _novoStatus) external apenasOwner loteExiste(_loteId) {
        lotes[_loteId].status = _novoStatus;
        emit StatusLoteAtualizado(_loteId, _novoStatus, block.timestamp);
    }
    
    function transferirPropriedade(address _novoOwner) external apenasOwner {
        require(_novoOwner != address(0), "Endereco invalido");
        owner = _novoOwner;
        tiposUsuario[_novoOwner] = TipoUsuario.Admin;
    }
}

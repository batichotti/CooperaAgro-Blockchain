# CooperaAgro - Sistema de Rastreabilidade Agrícola Blockchain

## 📋 Visão Geral

O **CooperaAgro** é um contrato inteligente em Solidity para rastreabilidade completa da cadeia produtiva agrícola. Baseado nas melhores práticas de sistemas como SIBRAAR da Embrapa, permite registrar e rastrear cada etapa do processo produtivo.

## 🌟 Características Principais

✅ **Rastreabilidade completa** desde plantio até consumidor  
✅ **Certificação orgânica** com validação automática  
✅ **Registro imutável** de todas as etapas na blockchain  
✅ **Múltiplos atores** (produtores, processadores, distribuidores)  
✅ **Certificações e auditorias** integradas  
✅ **Transparência total** para consumidores  
✅ **Integração com QR Code** para rastreamento fácil  

## 🔗 Cadeia Produtiva

```
Plantio → Cultivo → Colheita → Processamento → Transporte → Distribuição → Consumidor
   ✓        ✓         ✓           ✓              ✓             ✓            ✓
```

## 📦 Estrutura de Dados

### Lote
- ID único
- Produtor responsável
- Nome do produto
- Tipo (Grãos, Hortaliças, Frutas, Café, Cana-de-açúcar)
- Quantidade em kg
- Status atual
- Certificação orgânica

### Produtor
- Endereço blockchain
- Nome e CPF/CNPJ
- Localização
- Certificações
- Data de registro

### Processos Rastreados
1. **Plantio**: Cultivar, método, solo, insumos, irrigação, GPS
2. **Cultivo**: Tratamentos, fertilizantes, pesticidas, consumo de água
3. **Colheita**: Quantidade, metodologia, condições, qualidade
4. **Processamento**: Etapas, controle de qualidade, laudos
5. **Transporte**: Origem, destino, condições, temperatura
6. **Distribuição**: Estabelecimento final

## 🚀 Como Usar

### 1. Deploy do Contrato

```solidity
CooperaAgro cooperaAgro = new CooperaAgro();
```

### 2. Registrar Produtor

```solidity
cooperaAgro.registrarProdutor(
    0x123...,                      // Endereço
    "Fazenda São João",            // Nome
    "12.345.678/0001-90",         // CNPJ
    "Ribeirão Preto, SP",         // Localização
    "Certificação Orgânica MAPA"  // Certificações
);
```

### 3. Criar Lote

```solidity
uint256 loteId = cooperaAgro.criarLote(
    "Café Arábica Orgânico",      // Produto
    TipoProduto.Cafe,             // Tipo
    5000,                          // Quantidade (kg)
    block.timestamp,               // Data plantio
    "Fazenda São João - Talhão 3", // Localização
    true                           // Orgânico
);
```

### 4. Registrar Plantio

```solidity
string[] memory insumos = new string[](2);
insumos[0] = "Adubo orgânico";
insumos[1] = "Sementes certificadas";

cooperaAgro.registrarPlantio(
    loteId,
    "Catuaí Vermelho",            // Cultivar
    "Cultivo em pleno sol",       // Método
    "Latossolo Vermelho",         // Solo
    insumos,
    "Gotejamento",                 // Irrigação
    "-21.1767, -47.8208"          // GPS
);
```

### 5. Registrar Cultivo

```solidity
cooperaAgro.registrarCultivo(
    loteId,
    tratamentos,
    fertilizantes,
    pesticidas,      // Vazio para orgânico
    datasAplicacao,
    "Práticas agroecológicas",
    150000           // Água em litros
);
```

### 6. Consultar Rastreabilidade

```solidity
(
    Lote memory lote,
    Produtor memory produtor,
    ProcessoPlantio memory plantio,
    ProcessoCultivo memory cultivo,
    ProcessoColheita memory colheita,
    ProcessamentoIndustrial memory processamento
) = cooperaAgro.obterRastreabilidadeCompleta(loteId);
```

## 🎯 Casos de Uso

### 1. Café Orgânico Premium
```
Fazenda → Certificação Orgânica → Colheita Manual → Torrefação → Varejo Especializado
```

### 2. Açúcar Mascavo (similar ao SIBRAAR)
```
Canavial → Corte sem Queima → Processamento Artesanal → QR Code → Supermercado
```

### 3. Hortifruti da Agricultura Familiar
```
Sítio → Cultivo Orgânico → Feira do Produtor → Venda Direta
```

## 📱 Integração com QR Code

```javascript
// Gerar QR Code para o lote
const qrData = {
    loteId: loteId,
    contractAddress: "0x...",
    network: "polygon"
};

QRCode.toDataURL(JSON.stringify(qrData));
```

O consumidor escaneia o QR Code na embalagem e acessa:
- Origem do produto
- Histórico completo
- Certificações
- Práticas sustentáveis
- Laudos laboratoriais

## 🔐 Controle de Acesso

### Tipos de Usuários
- **Admin**: Gerencia sistema
- **Produtor**: Registra plantio, cultivo, colheita
- **Processador**: Registra processamento industrial
- **Transportador**: Registra transportes
- **Distribuidor**: Registra distribuição
- **Auditor**: Emite certificações e auditorias
- **Consumidor**: Consulta informações (público)

## ✅ Certificações Suportadas

- Certificação Orgânica (MAPA, IBD, Ecocert)
- Fair Trade
- Rainforest Alliance
- Denominação de Origem
- Boas Práticas Agrícolas
- ISO 22000
- Outras certificações customizadas

## 🌍 Sustentabilidade

O contrato rastreia:
- Consumo de água
- Uso de pesticidas (vetado para orgânicos)
- Práticas agroecológicas
- Manejo sustentável
- Conservação do solo
- Certificações ambientais

## 📊 Eventos e Auditoria

Todos os eventos são registrados:
```solidity
event LoteCriado(uint256 loteId, address produtor, string nomeProduto)
event ColheitaRegistrada(uint256 loteId, uint256 quantidade)
event CertificacaoAdicionada(uint256 loteId, string tipo)
event AuditoriaRealizada(uint256 loteId, bool aprovado)
```

## 🔧 Deploy em Diferentes Redes

### Polygon (Recomendado)
- Baixas taxas de gas
- Alta velocidade
- Bom para agricultura

```bash
npx hardhat run scripts/deploy.js --network polygon
```

### Ethereum
- Máxima segurança
- Mais caro

### BSC / Avalanche
- Alternativas com bom custo-benefício

## 💡 Benefícios

### Para Produtores
- ✅ Valorização do produto
- ✅ Acesso a mercados premium
- ✅ Transparência reconhecida
- ✅ Diferenciação competitiva

### Para Consumidores
- ✅ Confiança na origem
- ✅ Verificação de certificações
- ✅ Informações de sustentabilidade
- ✅ Rastreamento completo

### Para o Mercado
- ✅ Combate à fraude
- ✅ Conformidade regulatória
- ✅ Facilitação de auditorias
- ✅ Exportação facilitada

## 📚 Funções Principais

### Gerenciamento
- `registrarProdutor()` - Registra novo produtor
- `definirTipoUsuario()` - Define permissões
- `desativarProdutor()` - Desativa produtor

### Rastreabilidade
- `criarLote()` - Cria novo lote
- `registrarPlantio()` - Registra dados do plantio
- `registrarCultivo()` - Registra processo de cultivo
- `registrarColheita()` - Registra colheita
- `registrarProcessamento()` - Registra processamento
- `registrarTransporte()` - Registra transporte
- `registrarDistribuicao()` - Registra distribuição

### Certificação
- `adicionarCertificacao()` - Adiciona certificação
- `realizarAuditoria()` - Realiza auditoria

### Consulta
- `obterRastreabilidadeCompleta()` - Retorna todos os dados
- `obterCertificacoes()` - Lista certificações
- `obterLotesPorProdutor()` - Lista lotes de um produtor
- `verificarCertificadoOrganico()` - Verifica se é orgânico

## 🛡️ Segurança

- Registros imutáveis
- Controle de acesso por função
- Validação de dados
- Eventos auditáveis
- Proteção contra produtos orgânicos adulterados

## 📖 Inspiração

Baseado no **SIBRAAR** (Sistema Brasileiro de Agrorrastreabilidade) da Embrapa e nas melhores práticas de rastreabilidade agrícola com blockchain usadas por:
- JBS (rastreamento de carne)
- Minasul (Café da Origem)
- Granelli (açúcar mascavo)

## 🤝 Contribuindo

Este é um projeto open-source. Contribuições são bem-vindas!

## 📄 Licença

MIT License - Código aberto para uso comercial e não comercial.

---

**Desenvolvido para promover transparência, sustentabilidade e confiança na cadeia produtiva agrícola brasileira.** 🌱🇧🇷

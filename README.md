# CooperaAgro Blockchain

## Tipos de Blockchain

### PoW (Bitcoin)

Usa calculos matemáticos complexos (quebra de hash) e caros para persistir blocos na rede.

### PoS (Ethereum)

Usa apostas de Ethereum que alteram a probabilidade de uma máquina ser escolhida para persistir blocos na rede.

### PoA (Local)

Confia nos nós autorizados e os permite persistir blocos dado um conseso.

## Aplicações

### Pública - Mainnet e L2 (Polygon)

Sobre a Rede Ethereum:
- Roda códigos e transações na EVM (Ethereum Virtual Machine).
- Uso de *"Smart Contracts"* (códigos em Solidity sensiveis a eventos) que rodam na EVM.

O padrão Ethereum pode ser entendido como uma interface, soluções que rodam em uma rede Ethereum podem ser facilmente adaptadas para outras redes compatíveis com EVM. Ou seja, uma mesma solução pode ser utilizada na rede Principal (Mainnet) ou em uma rede de segunda camada (L2) como a Polygon, Arbitrum, Optimism, etc.

Solução com Foundry para deploy e do Ethers para interação com Backend.

Deploy com Foundry:
- `forge create` para fazer o deploy dos contratos.
- Solução mais barata possível para deploy.

Interação com Ethers:
- Basta salvar a ABI do contrato, o endereço do deploy e conectar à rede para interagir com ele.
- `ethers.Contract` para criar uma instância do contrato.
- `contract.functionName()` para chamar as funções do contrato.

### Privada (Local)

- Focado em casos de uso empresarial, como cadeias de suprimentos (Supply Chain).
- Permite criar redes blockchain privadas e/ou permissionadas, onde apenas participantes autorizados podem acessar e validar transações.
- Suporta contratos inteligentes, mas a implementação e a linguagem de programação podem variar dependendo da plataforma escolhida.
- Geralmente, as soluções de blockchain privadas são mais rápidas e escaláveis do que as públicas, pois não precisam lidar com a mesma quantidade de transações e participantes.
- Podem ser usadas para casos de uso específicos, como rastreamento de produtos, gerenciamento de identidade, etc.
- Normalmente, as soluções de blockchain privadas são mais seguras do que as públicas, pois os participantes são conhecidos e confiáveis.

#### Soluções baseadas em Ethereum

##### Hyperledger Besu

- Mantido pela ConsenSys.
- Permite criar redes blockchain privadas e permissionadas.
- Suporta contratos inteligentes escritos em **Solidity**, o que facilita a migração de soluções Ethereum para redes privadas.

##### Geth

- Mantido pela Ethereum Foundation.
- Permite criar redes blockchain privadas e permissionadas.
- Suporta contratos inteligentes escritos em **Solidity**, o que facilita a migração de soluções Ethereum para redes privadas.

##### Kurtosis

- [**UMA VEZ DESLIGADO NÃO PODE RETOMAR ATIVIDADE**](https://docs.kurtosis.com/enclave-stop)
- Mantido pela Kurtosis.
- Permite criar redes blockchain privadas e permissionadas.
- Baseado em Enclaves.
- Suporta contratos inteligentes escritos em **Solidity**, o que facilita a migração de soluções Ethereum para redes privadas.
- Focado em facilitar o desenvolvimento e teste de aplicações blockchain, oferecendo uma plataforma para criar ambientes de teste isolados e reproduzíveis.

#### Soluções Empresariais

##### Hyperledger Fabric

- Mantido pela **Linux Foundation**.
- Permite criar redes blockchain privadas e permissionadas.
- Opera em **Chaincode**, que é um programa que roda em um ambiente isolado (sandbox) e é executado pelos nós da rede.
- Suporta contratos inteligentes escritos em Go, JavaScript e Java.
- Solução mais completa, complexa e robusta.

##### Corda

- Mantido pela R3.
- Permite criar redes blockchain privadas e permissionadas.
- Opera em **Smart Contracts**, que são programas que rodam em um ambiente isolado (sandbox) e é executado pelos nós da rede.
- Suporta contratos inteligentes escritos em Kotlin e Java.

##### Quorum

- Mantido pela ConsenSys.
- Permite criar redes blockchain privadas e permissionadas.
- Opera em **Smart Contracts**, que são programas que rodam em um ambiente isolado (sandbox) e é executado pelos nós da rede.
- Suporta contratos inteligentes escritos em Solidity, o que facilita a migração de soluções Ethereum para redes privadas.

### Híbrida

Utiliza a ideia de enviar a Merkle Tree (estrutura de dados que representa o estado da blockchain) para uma rede pública (Mainnet ou L2) para garantir a imutabilidade dos dados, enquanto mantém os dados privados em uma rede local (privada). Dessa forma, é possível aproveitar a segurança e a imutabilidade da rede pública, enquanto mantém a privacidade dos dados em uma rede local.

Utilza redes locais para manter a lógica de negócios e os dados privados.
- Privacidade: os dados privados ficam em uma rede local, o que garante a privacidade dos dados.
- Imutabilidade: a Merkle Tree é persistida na rede Ethereum, o que garante a imutabilidade dos dados.
- Custo: o custo de persistir a Merkle Tree na rede Ethereum é menor do que operacionar toda a lógica de negócios e os dados na rede Ethereum, o que torna a solução mais barata.

#### Solução Ethereum pura

- Utiliza a rede Ethereum (Mainnet ou L2) para persistir a Merkle Tree, mas mantém a lógica de negócios e os dados privados em uma rede local (privada).
- Por ser totalmente feita em Ethereum, é mais fácil de migrar para a rede pública (Mainnet ou L2) caso seja necessário no futuro.

#### Solução L2/Hyperledger Fabric

- Utiliza uma rede de segunda camada (L2) para persistir a Merkle Tree da rede, enquanto mantém a lógica de negócios e os dados privados em uma rede local (privada).
- Maior liberdade para customização e otimização da solução e dos contratos.
- Os códigos podem ser mais complexos, completos e robustos, mas a migração para a rede pública (Mainnet ou L2) pode ser mais difícil no futuro.

## Qual escolher?

Depende.

Soluções públicas dependem da volatilidade do Ethereum, o que pode ser um problema para casos de uso que exigem previsibilidade de custos. **Toda interação aditiva com uma rede pública (Mainnet ou L2) tem um custo associado, o que pode ser um problema para casos de uso que exigem muitas interações ou que têm um orçamento limitado.** Além disso, as soluções públicas podem ser mais lentas devido à necessidade de consenso entre os nós da rede.

Soluções privadas, por outro lado, podem ser mais rápidas e escaláveis, mas podem ser menos seguras devido à falta de descentralização e à possibilidade de ataques internos. Quanto aos custos, as soluções privadas geralmente exigem investimentos em infraestrutura e manutenção.

Soluções híbridas podem ser uma boa opção para casos de uso que exigem privacidade e imutabilidade, mas podem ser mais complexas de implementar e manter.

| Solução | Privada, Pública ou Híbrida? | Tecnologias/Linguagens | Custo |
|---------|------------------------------|----------------------|-------|
| Ethereum Mainnet/L2 | Pública | Solidity, EVM | Alto (Mainnet), Médio (L2) |
| Hyperledger Besu | Privada | Solidity, EVM | Infraestrutura |
| Geth | Privada | Solidity, EVM | Infraestrutura |
| Hyperledger Fabric | Privada | Go, JavaScript, Java (Chaincode) | Infraestrutura |
| Corda | Privada | Kotlin, Java | Infraestrutura |
| Quorum | Privada | Solidity, EVM | Infraestrutura |
| Ethereum Pura (Híbrida) | Híbrida | Solidity, EVM | Infraestrutura + L2* |
| L2/Hyperledger Fabric (Híbrida) | Híbrida | Solidity + Go/JavaScript/Java | Infraestrutura + L2* |

> O custo de persistir a Merkle Tree na rede Ethereum (Mainnet ou L2) é menor do que operacionar toda a lógica de negócios e os dados na rede Ethereum, o que torna a solução mais barata.

### Custos para rodar um contrato completo

Rodamos o deploy e um ciclo de vida inteiro de um contrato de registro de transporte de produtos, para avaliar os custos envolvidos de usar a rede pública como motor.
*Foi utilizado o Foundry e o Ethers para calcular o preço de deploy e o gasto com o gás.*

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.31;
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
        apenasNoEstado(_id_contrato, ESTADO_DO_CONTRATO.PACOTE_ENVIADO_PARA_COOPERATIVA)
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

        if (estados[_id_contrato] != ESTADO_DO_CONTRATO.ENVIANDO_PACOTES_PARA_ESCOLAS) {
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
```

#### L1 (Mainnet) TestNet Sepolia
- Deploy custou 0,00000147 ETH (~0,0029 USD)
- 1 Ciclo que custou 0,00000103 ETH (~0,0021 USD)

#### L2 (Polygon) Testnet Amoy
- Deploy custou 0,00000484 ETH (~0,0096 USD)
- 1 Ciclo que custou 0,00000371 ETH (~0,0074 USD)

### Custos para guardar a Merkle Tree

Rodamos o deploy e uma adição de merkle tree, para avaliar os custos envolvidos de usar a rede pública como motor.
*Foi utilizado o Foundry e o Ethers para calcular o preço de deploy e o gasto com o gás.*

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract PublicNotary {
    mapping(uint256 => bytes32) public batchProofs; // Bloco -> Merkle Root

    function anchorBatch(uint256 _batchId, bytes32 _merkleRoot) public {
        batchProofs[_batchId] = _merkleRoot;
    }
}
```

#### L1 (Mainnet) TestNet Sepolia
- Deploy custou 0,00000048 ETH (~0,00098 USD)
- 1 Ciclo que custou 0,00000007 ETH (~0,00014 USD)

#### L2 (Polygon) TestNet Amoy
- Deploy custou 0,00000301 ETH (~0,0061 USD)
- 1 Ciclo que custou 0,00000053 ETH (~0,0011 USD)

### Custo para manter uma Rede Privada

Pensando em um servidor AWS com 1000 requisições diárias, funcionando 6hrs - 21hrs, mais o armazenamento e EIP

| Recurso | Unidade / Tipo | Conta (Preço Unitário × Quantidade) | Custo Mensal (USD) |
|---------|----------------|-------------------------------------|-------------------|
| Computação (Ethereum) | 1x t3.medium | 450h × $0,076/h | $34,20 |
| Computação (Fabric) | 3x t3.small | 3 × (450h × $0,038/h) | $51,30 |
| Disco (EBS gp3) | 50 GB | 50GB × $0,119/GB (Fixo) | $5,95 |
| IP Estático (EIP) | 1x IPv4 Fixo | 280h × $0,005/h (Ocioso) | $1,40 |
| Tráfego | ~160 MB/mês | Faixa gratuita (até 100GB) | $0,00 |

Já para um servidor 24/7

| Recurso | Unidade / Tipo | Conta (Preço Unitário × 730h) | Custo Mensal (USD) |
|---------|----------------|-------------------------------|-------------------|
| Computação (Ethereum) | 1x t3.medium | 730h × $0,076/h | $55,48 |
| Computação (Fabric) | 3x t3.small | 3 × (730h × $0,038/h) | $83,22 |
| Disco (EBS gp3) | 50 GB | 50GB × $0,119/GB | $5,95 |
| IP Estático (EIP) | 1x IPv4 Fixo | 730h × $0,00 (Em uso) | $0,00 |
| Tráfego (1k req/dia) | ~160 MB/mês | Faixa Gratuita | $0,00 |

Comparação entre rodar uma rede Ethereum (Geth/Besu) ou em Hyperleger Fabric

| Cenário | Ethereum (1 Nó) | Fabric (3 Nós) |
|---------|-----------------|----------------|
| 6h - 21h (Brasil) | $41,55 | $58,65 |
| 24/7 (Brasil) | $61,43 | $89,17 |

> Valores estimados pelo Gemini Pro para região do Brasil

### Custo para manter uma Rede Híbrida

O custo de rodar uma rede Híbrida subindo a Merkle Tree é o custo da infraestrutura da rede local mais o upload da hash da arvore, dessa forma o custo total é:

#### Ethereum

#### Hyperleger Fabric

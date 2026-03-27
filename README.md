# **CooperaAgro Blockchain**

# Tipos de Blockchain

## PoW (Bitcoin)

- Usa calculos matemáticos complexos (quebra de hash) e caros para persistir blocos na rede.

## PoS (Ethereum)

- Usa apostas de Ethereum que alteram a probabilidade de uma máquina ser escolhida para persistir blocos na rede.

## PoA (Local)

- Confia nos nós autorizados e os permite persistir blocos dado um conseso.

# Aplicações

## Mainnet e L2 (Pública)

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

## Local (Privada)

- Focado em casos de uso empresarial, como cadeias de suprimentos (Supply Chain).
- Permite criar redes blockchain privadas e/ou permissionadas, onde apenas participantes autorizados podem acessar e validar transações.
- Suporta contratos inteligentes, mas a implementação e a linguagem de programação podem variar dependendo da plataforma escolhida.
- Geralmente, as soluções de blockchain privadas são mais rápidas e escaláveis do que as públicas, pois não precisam lidar com a mesma quantidade de transações e participantes.
- Podem ser usadas para casos de uso específicos, como rastreamento de produtos, gerenciamento de identidade, etc.
- Normalmente, as soluções de blockchain privadas são mais seguras do que as públicas, pois os participantes são conhecidos e confiáveis.

### Soluções Ethereum-like

Hyperledger Besu:
- Mantido pela ConsenSys.
- Permite criar redes blockchain privadas e permissionadas.
- Suporta contratos inteligentes escritos em **Solidity**, o que facilita a migração de soluções Ethereum para redes privadas.

Geth:
- Mantido pela Ethereum Foundation.
- Permite criar redes blockchain privadas e permissionadas.
- Suporta contratos inteligentes escritos em **Solidity**, o que facilita a migração de soluções Ethereum para redes privadas.

Kurtosis:
- [**UMA VEZ DESLIGADO NÃO PODE RETOMAR ATIVIDADE**](https://docs.kurtosis.com/enclave-stop)
- Mantido pela Kurtosis.
- Permite criar redes blockchain privadas e permissionadas.
- Baseado em Enclaves.
- Suporta contratos inteligentes escritos em **Solidity**, o que facilita a migração de soluções Ethereum para redes privadas.
- Focado em facilitar o desenvolvimento e teste de aplicações blockchain, oferecendo uma plataforma para criar ambientes de teste isolados e reproduzíveis.

### Soluções Empresariais

Hyperledger Fabric:
- Mantido pela **Linux Foundation**.
- Permite criar redes blockchain privadas e permissionadas.
- Opera em **Chaincode**, que é um programa que roda em um ambiente isolado (sandbox) e é executado pelos nós da rede.
- Suporta contratos inteligentes escritos em Go, JavaScript e Java.
- Solução mais completa, complexa e robusta.

Corda:
- Mantido pela R3.
- Permite criar redes blockchain privadas e permissionadas.
- Opera em **Smart Contracts**, que são programas que rodam em um ambiente isolado (sandbox) e é executado pelos nós da rede.
- Suporta contratos inteligentes escritos em Kotlin e Java.

Quorum:
- Mantido pela ConsenSys.
- Permite criar redes blockchain privadas e permissionadas.
- Opera em **Smart Contracts**, que são programas que rodam em um ambiente isolado (sandbox) e é executado pelos nós da rede.
- Suporta contratos inteligentes escritos em Solidity, o que facilita a migração de soluções Ethereum para redes privadas.

## Híbrida

Utiliza a ideia de enviar a Merkle Tree (estrutura de dados que representa o estado da blockchain) para uma rede pública (Mainnet ou L2) para garantir a imutabilidade dos dados, enquanto mantém os dados privados em uma rede local (privada). Dessa forma, é possível aproveitar a segurança e a imutabilidade da rede pública, enquanto mantém a privacidade dos dados em uma rede local.

Utilza redes locais para manter a lógica de negócios e os dados privados.
- Privacidade: os dados privados ficam em uma rede local, o que garante a privacidade dos dados.
- Imutabilidade: a Merkle Tree é persistida na rede Ethereum, o que garante a imutabilidade dos dados.
- Custo: o custo de persistir a Merkle Tree na rede Ethereum é menor do que operacionar toda a lógica de negócios e os dados na rede Ethereum, o que torna a solução mais barata.

### Solução Ethereum pura

- Utiliza a rede Ethereum (Mainnet ou L2) para persistir a Merkle Tree, mas mantém a lógica de negócios e os dados privados em uma rede local (privada).
- Por ser totalmente feita em Ethereum, é mais fácil de migrar para a rede pública (Mainnet ou L2) caso seja necessário no futuro.

### Solução L2/Hyperledger Fabric

- Utiliza uma rede de segunda camada (L2) para persistir a Merkle Tree da rede, enquanto mantém a lógica de negócios e os dados privados em uma rede local (privada).
- Maior liberdade para customização e otimização da solução e dos contratos.
- Os códigos podem ser mais complexos, completos e robustos, mas a migração para a rede pública (Mainnet ou L2) pode ser mais difícil no futuro.

# Qual escolher?

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

\* O custo de persistir a Merkle Tree na rede Ethereum (Mainnet ou L2) é menor do que operacionar toda a lógica de negócios e os dados na rede Ethereum, o que torna a solução mais barata.
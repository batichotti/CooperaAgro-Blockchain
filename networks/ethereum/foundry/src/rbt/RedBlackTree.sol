// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. Importamos a interface
import "./IRedBlackTree.sol";

// 2. Declaramos que nosso contrato obedece à interface
contract RedBlackTree is IRedBlackTree {

    enum Color { RED, BLACK }

    // Struct interno do nó — armazena um array dinâmico de Metric (id, hash).
    struct Node {
        uint256  left;     // ID do nó à esquerda (0 = null)
        uint256  right;    // ID do nó à direita  (0 = null)
        int256   key;      // Chave usada para ordenar a árvore
        Metric[] metrics;  // Array de tuplas (id, hash)
        Color    color;    // Cor (RED ou BLACK)
    }

    // "Memória RAM" da árvore: guarda os nós pelo seu ID único.
    mapping(uint256 => Node) public memoryPool;

    // Alocador de IDs (substituto do malloc)
    uint256 private nextNodeId = 1;

    // Ponteiro para a raiz da árvore (0 = árvore vazia)
    uint256 public root;

    // -------------------------------------------------------------------------
    // FUNÇÕES AUXILIARES
    // -------------------------------------------------------------------------

    /// @dev Copia um array calldata de Metric para o storage de um nó.
    function _storeMetrics(uint256 nodeId, Metric[] calldata _metrics) private {
        delete memoryPool[nodeId].metrics; // limpa antes de reescrever
        for (uint256 i = 0; i < _metrics.length; i++) {
            memoryPool[nodeId].metrics.push(_metrics[i]);
        }
    }

    /// @dev Cria um novo nó na memória e retorna o seu ID.
    function createNode(int256 _key, Metric[] calldata _metrics)
        private
        returns (uint256)
    {
        uint256 newNodeId = nextNodeId;
        nextNodeId++;

        // Inicializa o nó (o array metrics começa vazio e é populado a seguir)
        memoryPool[newNodeId].left  = 0;
        memoryPool[newNodeId].right = 0;
        memoryPool[newNodeId].key   = _key;
        memoryPool[newNodeId].color = Color.RED;
        _storeMetrics(newNodeId, _metrics);

        return newNodeId;
    }

    function isRed(uint256 nodeId) private view returns (bool) {
        if (nodeId == 0) return false; // nós nulos são pretos
        return memoryPool[nodeId].color == Color.RED;
    }

    function invertColors(uint256 h) private {
        memoryPool[h].color                   = Color.RED;
        memoryPool[memoryPool[h].left].color  = Color.BLACK;
        memoryPool[memoryPool[h].right].color = Color.BLACK;
    }

    function leftRotation(uint256 h) private returns (uint256) {
        uint256 x             = memoryPool[h].right;
        memoryPool[h].right   = memoryPool[x].left;
        memoryPool[x].left    = h;
        memoryPool[x].color   = memoryPool[h].color;
        memoryPool[h].color   = Color.RED;
        return x;
    }

    function rightRotation(uint256 h) private returns (uint256) {
        uint256 x             = memoryPool[h].left;
        memoryPool[h].left    = memoryPool[x].right;
        memoryPool[x].right   = h;
        memoryPool[x].color   = memoryPool[h].color;
        memoryPool[h].color   = Color.RED;
        return x;
    }

    // -------------------------------------------------------------------------
    // FUNÇÕES DE INSERÇÃO
    // -------------------------------------------------------------------------

    /// @dev Recursão interna de inserção / atualização.
    function _insert(uint256 h, int256 _key, Metric[] calldata _metrics)
        private
        returns (uint256)
    {
        // Nó nulo → aloca e cria um novo nó vermelho
        if (h == 0) {
            return createNode(_key, _metrics);
        }

        // Navega pela árvore comparando a chave
        if (_key < memoryPool[h].key) {
            memoryPool[h].left  = _insert(memoryPool[h].left,  _key, _metrics);
        } else if (_key > memoryPool[h].key) {
            memoryPool[h].right = _insert(memoryPool[h].right, _key, _metrics);
        } else {
            // Chave já existe → substitui o array de métricas
            _storeMetrics(h, _metrics);
        }

        // Balanceamento LLRB
        if (isRed(memoryPool[h].right) && !isRed(memoryPool[h].left)) {
            h = leftRotation(h);
        }
        if (isRed(memoryPool[h].left) && isRed(memoryPool[memoryPool[h].left].left)) {
            h = rightRotation(h);
        }
        if (isRed(memoryPool[h].left) && isRed(memoryPool[h].right)) {
            invertColors(h);
        }

        return h;
    }

    /// @notice Insere ou atualiza um nó com um array de métricas (id, hash).
    /// @param _key     Chave inteira que identifica o nó.
    /// @param _metrics Array de Metric — cada entrada é (uint256 id, bytes32 hash).
    function insert(int256 _key, Metric[] calldata _metrics) external override {
        root = _insert(root, _key, _metrics);
        memoryPool[root].color = Color.BLACK; // a raiz é sempre preta
    }

    // -------------------------------------------------------------------------
    // FUNÇÕES DE CONSULTA
    // -------------------------------------------------------------------------

    /// @notice Busca e retorna o array de métricas associado a uma chave.
    /// @param _key Chave inteira a ser buscada.
    /// @return Array de Metric do nó encontrado.
    function getMetrics(int256 _key)
        external
        view
        override
        returns (Metric[] memory)
    {
        uint256 currentId = root;

        while (currentId != 0) {
            if (_key == memoryPool[currentId].key) {
                return memoryPool[currentId].metrics;
            } else if (_key < memoryPool[currentId].key) {
                currentId = memoryPool[currentId].left;
            } else {
                currentId = memoryPool[currentId].right;
            }
        }

        revert("Chave nao encontrada na arvore");
    }

    // -------------------------------------------------------------------------
    // UTILITÁRIO
    // -------------------------------------------------------------------------

    /// @notice Gera o hash keccak256 de uma string — útil para montar o campo
    ///         `hash` de cada Metric antes de chamar insert().
    /// @param _value Valor da métrica em formato string.
    /// @return Hash bytes32 correspondente.
    function hashMetric(string calldata _value) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_value));
    }
}

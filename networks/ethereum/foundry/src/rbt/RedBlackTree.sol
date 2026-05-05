// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IRedBlackTree.sol";

contract RedBlackTree is IRedBlackTree {

    enum Color { RED, BLACK }

    struct Node {
        uint256    left;
        uint256    right;
        int256     key;
        Metric[]   metrics;
        Evidence[] evidences;
        Color      color;
    }

    mapping(uint256 => Node) public memoryPool;
    uint256 private nextNodeId = 1;
    uint256 public root;

    // -------------------------------------------------------------------------
    // FUNÇÕES AUXILIARES
    // -------------------------------------------------------------------------

    /// @dev Copia um array calldata de Metric para o storage de um nó.
    function _storeMetrics(uint256 nodeId, Metric[] calldata _metrics) private {
        delete memoryPool[nodeId].metrics;
        for (uint256 i = 0; i < _metrics.length; i++) {
            memoryPool[nodeId].metrics.push(_metrics[i]);
        }
    }

    /// @dev Copia um array calldata de Evidence para o storage de um nó.
    function _storeEvidences(uint256 nodeId, Evidence[] calldata _evidences) private {
        delete memoryPool[nodeId].evidences;
        for (uint256 i = 0; i < _evidences.length; i++) {
            memoryPool[nodeId].evidences.push(_evidences[i]);
        }
    }

    /// @dev Cria um novo nó na memória e retorna o seu ID.
    function createNode(
        int256 _key,
        Metric[] calldata _metrics,
        Evidence[] calldata _evidences
    ) private returns (uint256) {
        uint256 newNodeId = nextNodeId;
        nextNodeId++;

        memoryPool[newNodeId].left  = 0;
        memoryPool[newNodeId].right = 0;
        memoryPool[newNodeId].key   = _key;
        memoryPool[newNodeId].color = Color.RED;
        _storeMetrics(newNodeId, _metrics);
        _storeEvidences(newNodeId, _evidences);

        return newNodeId;
    }

    function isRed(uint256 nodeId) private view returns (bool) {
        if (nodeId == 0) return false;
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
    function _insert(
        uint256 h,
        int256 _key,
        Metric[] calldata _metrics,
        Evidence[] calldata _evidences
    ) private returns (uint256) {
        if (h == 0) {
            return createNode(_key, _metrics, _evidences);
        }

        if (_key < memoryPool[h].key) {
            memoryPool[h].left  = _insert(memoryPool[h].left,  _key, _metrics, _evidences);
        } else if (_key > memoryPool[h].key) {
            memoryPool[h].right = _insert(memoryPool[h].right, _key, _metrics, _evidences);
        } else {
            // Chave já existe → substitui métricas e evidências
            _storeMetrics(h, _metrics);
            _storeEvidences(h, _evidences);
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

    /// @notice Insere ou atualiza um nó com métricas e evidências.
    function insert(
        int256 _key,
        Metric[] calldata _metrics,
        Evidence[] calldata _evidences
    ) external override {
        root = _insert(root, _key, _metrics, _evidences);
        memoryPool[root].color = Color.BLACK;
    }

    // -------------------------------------------------------------------------
    // FUNÇÕES DE CONSULTA
    // -------------------------------------------------------------------------

    /// @dev Navega até o nó com a chave dada e retorna seu ID; reverte se não encontrado.
    function _findNode(int256 _key) private view returns (uint256) {
        uint256 currentId = root;
        while (currentId != 0) {
            if (_key == memoryPool[currentId].key) {
                return currentId;
            } else if (_key < memoryPool[currentId].key) {
                currentId = memoryPool[currentId].left;
            } else {
                currentId = memoryPool[currentId].right;
            }
        }
        revert("Chave nao encontrada na arvore");
    }

    /// @notice Retorna o array de métricas associado a uma chave.
    function getMetrics(int256 _key)
        external
        view
        override
        returns (Metric[] memory)
    {
        return memoryPool[_findNode(_key)].metrics;
    }

    /// @notice Retorna o array de evidências associado a uma chave.
    function getEvidences(int256 _key)
        external
        view
        override
        returns (Evidence[] memory)
    {
        return memoryPool[_findNode(_key)].evidences;
    }

    // -------------------------------------------------------------------------
    // UTILITÁRIO
    // -------------------------------------------------------------------------

    /// @notice Gera o hash keccak256 de uma string.
    function hash(string calldata _value) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_value));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. Importamos a interface
import "./IRedBlackTree.sol";

// 2. Declaramos que nosso contrato obedece à interface
contract RedBlackTree is IRedBlackTree {
    
    enum Color { RED, BLACK }

    // Agora o struct está IDÊNTICO ao seu C!
    struct Node {
        uint256 left;   // ID do nó à esquerda (0 = null)
        uint256 right;  // ID do nó à direita (0 = null)
        int256 key;     // A chave usada para ordenar a árvore
        int256 data;    // O dado armazenado
        Color color;    // Cor (RED ou BLACK)
    }

    // Este mapping é a nossa "Memória RAM". Ele guarda os nós usando um ID único.
    mapping(uint256 => Node) public memoryPool;
    
    // Este é o nosso alocador de memória (substituto do malloc)
    uint256 private nextNodeId = 1; 

    // Ponteiro para a raiz da árvore (0 = árvore vazia)
    uint256 public root;

    // --- FUNÇÕES AUXILIARES ---

    // Equivalente ao seu RBT_Create + malloc
    function createNode(int256 _key, int256 _data) private returns (uint256) {
        uint256 newNodeId = nextNodeId; // Pega um ID livre
        nextNodeId++; // Prepara o ID para o próximo nó
        
        // Salva o nó na "memória"
        memoryPool[newNodeId] = Node({
            left: 0,
            right: 0,
            key: _key,
            data: _data,
            color: Color.RED
        });
        
        return newNodeId; // Retorna o "ponteiro" (ID) do nó criado
    }

    function isRed(uint256 nodeId) private view returns (bool) {
        if (nodeId == 0) return false; // 0 é o nosso "null" (Nós nulos são pretos)
        return memoryPool[nodeId].color == Color.RED;
    }

    function invertColors(uint256 h) private {
        memoryPool[h].color = Color.RED;
        memoryPool[memoryPool[h].left].color = Color.BLACK;
        memoryPool[memoryPool[h].right].color = Color.BLACK;
    }

    function leftRotation(uint256 h) private returns (uint256) {
        uint256 x = memoryPool[h].right;
        memoryPool[h].right = memoryPool[x].left;
        memoryPool[x].left = h;
        
        memoryPool[x].color = memoryPool[h].color;
        memoryPool[h].color = Color.RED;
        
        return x;
    }

    function rightRotation(uint256 h) private returns (uint256) {
        uint256 x = memoryPool[h].left;
        memoryPool[h].left = memoryPool[x].right;
        memoryPool[x].right = h;
        
        memoryPool[x].color = memoryPool[h].color;
        memoryPool[h].color = Color.RED;
        
        return x;
    }

    // --- FUNÇÕES DE INSERÇÃO ---

    // Equivalente a: RBT_R_Insert(RBT **T, int key, int data)
    function _insert(uint256 h, int256 _key, int256 _data) private returns (uint256) {
        // Se chegamos no "null", alocamos e criamos um novo nó
        if (h == 0) {
            return createNode(_key, _data);
        }

        // Navegação recursiva comparando o _key de entrada com o key do nó atual
        if (_key < memoryPool[h].key) {
            memoryPool[h].left = _insert(memoryPool[h].left, _key, _data);
        } else if (_key > memoryPool[h].key) {
            memoryPool[h].right = _insert(memoryPool[h].right, _key, _data);
        } else {
            // Se a chave já existir, apenas atualizamos o dado
            memoryPool[h].data = _data; 
        }

        // Balanceamento da árvore
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

    // Função pública. Equivalente a: RBT_Insert
    function insert(int256 _key, int256 _data) external override {
        root = _insert(root, _key, _data);
        memoryPool[root].color = Color.BLACK;
    }
    
    // O "override" é obrigatório aqui para provar que você está cumprindo a interface
    function getData(int256 _key) external view override returns (int256) {
        uint256 currentId = root;

        // Enquanto não chegarmos em um nó "null" (0)
        while (currentId != 0) {
            if (_key == memoryPool[currentId].key) {
                // Achamos a chave! Retorna o dado.
                return memoryPool[currentId].data;
            } else if (_key < memoryPool[currentId].key) {
                // A chave buscada é menor, vamos para a esquerda
                currentId = memoryPool[currentId].left;
            } else {
                // A chave buscada é maior, vamos para a direita
                currentId = memoryPool[currentId].right;
            }
        }

        // Se o while terminar e não acharmos nada, revertemos a transação com erro
        revert("Chave nao encontrada na arvore");
    }
}
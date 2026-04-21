// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRedBlackTree {

    // Representa uma única métrica: um identificador e seu hash.
    struct Metric {
        uint256 id;    // Identificador da métrica
        bytes32 hash;  // Hash do valor da métrica (keccak256)
    }

    // Insere (ou atualiza) um nó na árvore com a chave e um array de métricas.
    function insert(int256 _key, Metric[] calldata _metrics) external;

    // Busca e retorna o array de métricas associado a uma chave.
    function getMetrics(int256 _key) external view returns (Metric[] memory);
}

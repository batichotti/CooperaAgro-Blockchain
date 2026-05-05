// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRedBlackTree {

    struct Metric {
        uint256 id;
        bytes32 hash;
    }

    struct Evidence {
        uint256 id;
        bytes32 hash;
    }

    // Insere (ou atualiza) um nó com métricas E evidências.
    function insert(
        int256 _key,
        Metric[] calldata _metrics,
        Evidence[] calldata _evidences
    ) external;

    // Retorna o array de métricas associado a uma chave.
    function getMetrics(int256 _key) external view returns (Metric[] memory);

    // Retorna o array de evidências associado a uma chave.
    function getEvidences(int256 _key) external view returns (Evidence[] memory);
}
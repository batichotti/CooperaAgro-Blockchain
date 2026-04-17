// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// O nome começa com "I" por convenção
interface IRedBlackTree {
    
    // Qualquer um que usar esta interface sabe que pode inserir dados assim:
    function insert(int256 _key, int256 _data) external;

    // E sabe que pode buscar os dados assim (mesmo que a gente ainda não tenha escrito a lógica):
    function getData(int256 _key) external view returns (int256);
}
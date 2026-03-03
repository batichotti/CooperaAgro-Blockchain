// SPDX-License-Identifier: MIT

pragma solidity ^0.8.31;

contract MultiCalculator{

    mapping(uint256 => uint256) ultimo_resultado;
    uint256 id_counter = 0;

    function create_instance() public returns(uint256){
        return ++id_counter;
    }

    error InvalidId(uint256 requested, uint256 available);
    error DivisionByZero();
    error NegativeResult();

    function add(uint256 id_rastreamento, uint256 numero1, uint256 numero2 ) public {
        require(id_rastreamento > id_counter, InvalidId(id_rastreamento, id_counter));
        ultimo_resultado[id_rastreamento] = numero1 + numero2;
    }

    function sub(uint256 id_rastreamento, uint256 numero1, uint256 numero2 ) public {
        require(id_rastreamento > id_counter, InvalidId(id_rastreamento, id_counter));
        if (numero2 > numero1) revert NegativeResult();
        ultimo_resultado[id_rastreamento] = numero1 - numero2;
    }

    function mult(uint256 id_rastreamento, uint256 numero1, uint256 numero2 ) public {
        require(id_rastreamento > id_counter, InvalidId(id_rastreamento, id_counter));
        ultimo_resultado[id_rastreamento] = numero1 * numero2;
    }

    function div(uint256 id_rastreamento, uint256 numero1, uint256 numero2 ) public {
        require(id_rastreamento > id_counter, InvalidId(id_rastreamento, id_counter));
        if (numero2 == 0) revert DivisionByZero();
        ultimo_resultado[id_rastreamento] = numero1 / numero2;
    }

    function get(uint256 id_rastreamento) public view returns(uint256){
        require(id_rastreamento > id_counter, InvalidId(id_rastreamento, id_counter));
        return ultimo_resultado[id_rastreamento];
    }

}
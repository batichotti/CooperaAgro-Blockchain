// SPDX-License-Identifier: MIT

pragma solidity ^0.8.31;

contract MultiCalculator{

    mapping(uint256 => uint256) ultimo_resultado;
    uint256 id_counter = 0;

    function create_instance() public returns(uint256){
        return ++id_counter;
    }

    error IdOutOfBounds(uint256 providedId, uint256 maximumAllowedId);

    function check_id(uint256 id_rastreamento) public view {
        if(id_rastreamento > id_counter) revert IdOutOfBounds(id_rastreamento, id_counter);
    }

    function add(uint256 id_rastreamento, uint256 numero1, uint256 numero2 ) public {
        check_id(id_rastreamento);
        ultimo_resultado[id_rastreamento] = numero1 + numero2;
    }

    function sub(uint256 id_rastreamento, uint256 numero1, uint256 numero2 ) public {
        check_id(id_rastreamento);
        ultimo_resultado[id_rastreamento] = numero1 - numero2;
    }

    function mult(uint256 id_rastreamento, uint256 numero1, uint256 numero2 ) public {
        check_id(id_rastreamento);
        ultimo_resultado[id_rastreamento] = numero1 * numero2;
    }

    function div(uint256 id_rastreamento, uint256 numero1, uint256 numero2 ) public {
        check_id(id_rastreamento);
        ultimo_resultado[id_rastreamento] = numero1 / numero2;
    }

    function get(uint256 id_rastreamento) public view returns(uint256){
        check_id(id_rastreamento);
        return ultimo_resultado[id_rastreamento];
    }

}
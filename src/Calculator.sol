// SPDX-License-Identifier: MIT

pragma solidity ^0.8.31;

contract Calculator{

    uint256 ultimo_resultado;

    function add( uint256 numero1, uint256 numero2 ) public returns(uint256){
        ultimo_resultado = numero1 + numero2;
        return ultimo_resultado;
    }

    function get() public view returns(uint256){
        return ultimo_resultado;
    }

}
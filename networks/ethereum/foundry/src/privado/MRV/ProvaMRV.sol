// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RegistroMRV {
    struct Prova {
        string ipfsCID;
        uint256 dataRegistro;
    }

    // Mapeamento: ID do Produtor -> (ID da Produção -> Dados da Prova)
    mapping(uint256 => mapping(uint256 => Prova)) public historicoDeProvas;

    event ProvaRegistrada(uint256 indexed idProdutor, uint256 indexed idProducao, string cid);

    function registrarVerificacao(uint256 _idProdutor, uint256 _idProducao, string memory _cid) public {
        historicoDeProvas[_idProdutor][_idProducao] = Prova(_cid, block.timestamp);
        emit ProvaRegistrada(_idProdutor, _idProducao, _cid);
    }
}

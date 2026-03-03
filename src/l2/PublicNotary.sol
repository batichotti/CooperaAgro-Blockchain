// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract PublicNotary {
    mapping(uint256 => bytes32) public batchProofs; // Bloco -> Merkle Root

    function anchorBatch(uint256 _batchId, bytes32 _merkleRoot) public {
        batchProofs[_batchId] = _merkleRoot;
    }
}
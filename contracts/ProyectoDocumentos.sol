
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


// ProyectoDocumentos.sol
contract ProyectoDocumentos {
    struct Documento {
        string cid;        // Hash o CID (IPFS, etc.)
        uint256 timestamp; // Momento de registro
    }

    mapping(address => Documento[]) private documentos;

    event DocumentoGuardado(address indexed autor, string cid, uint256 timestamp);

    function guardarDocumento(string memory _cid) public {
        documentos[msg.sender].push(Documento(_cid, block.timestamp));
        emit DocumentoGuardado(msg.sender, _cid, block.timestamp);
    }

    function obtenerMisDocumentos() public view returns (Documento[] memory) {
        return documentos[msg.sender];
    }
}

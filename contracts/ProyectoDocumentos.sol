// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ProyectoDocumentos {
    enum TipoDocumento { Otro, Acta, Contrato, Factura, Informe, Soporte }
    enum EstadoDocumento { Vigente, Anulado, Reemplazado }

    struct Documento {
        string cid;
        bytes32 hashArchivo;
        uint256 proyectoId;
        TipoDocumento tipoDocumento;
        uint256 version;
        EstadoDocumento estado;
        address autor;
        uint256 timestamp;
    }

    mapping(address => Documento[]) private documentosPorAutor;
    mapping(uint256 => Documento[]) private documentosPorProyecto;

    event DocumentoGuardado(
        address indexed autor,
        uint256 indexed proyectoId,
        string cid,
        bytes32 hashArchivo,
        TipoDocumento tipoDocumento,
        uint256 version,
        uint256 timestamp
    );

    event EstadoActualizado(
        uint256 indexed proyectoId,
        uint256 indice,
        EstadoDocumento nuevoEstado
    );

    function guardarDocumento(
        string memory _cid,
        bytes32 _hashArchivo,
        uint256 _proyectoId,
        TipoDocumento _tipoDocumento,
        uint256 _version
    ) public {
        require(bytes(_cid).length > 0, "CID vacio");
        require(_hashArchivo != bytes32(0), "Hash vacio");
        require(_proyectoId > 0, "Proyecto invalido");
        require(_version > 0, "Version invalida");

        Documento memory doc = Documento({
            cid: _cid,
            hashArchivo: _hashArchivo,
            proyectoId: _proyectoId,
            tipoDocumento: _tipoDocumento,
            version: _version,
            estado: EstadoDocumento.Vigente,
            autor: msg.sender,
            timestamp: block.timestamp
        });

        documentosPorAutor[msg.sender].push(doc);
        documentosPorProyecto[_proyectoId].push(doc);

        emit DocumentoGuardado(
            msg.sender,
            _proyectoId,
            _cid,
            _hashArchivo,
            _tipoDocumento,
            _version,
            block.timestamp
        );
    }

    function obtenerMisDocumentos() public view returns (Documento[] memory) {
        return documentosPorAutor[msg.sender];
    }

    function obtenerDocumentosPorProyecto(uint256 _proyectoId)
        public
        view
        returns (Documento[] memory)
    {
        return documentosPorProyecto[_proyectoId];
    }

    function actualizarEstado(
        uint256 _proyectoId,
        uint256 _indice,
        EstadoDocumento _nuevoEstado
    ) public {
        Documento[] storage docs = documentosPorProyecto[_proyectoId];
        require(_indice < docs.length, "Indice invalido");
        require(docs[_indice].autor == msg.sender, "No autorizado");

        docs[_indice].estado = _nuevoEstado;

        Documento[] storage misDocs = documentosPorAutor[msg.sender];
        for (uint256 i = 0; i < misDocs.length; i++) {
            if (
                misDocs[i].proyectoId == _proyectoId &&
                keccak256(bytes(misDocs[i].cid)) ==
                keccak256(bytes(docs[_indice].cid)) &&
                misDocs[i].version == docs[_indice].version
            ) {
                misDocs[i].estado = _nuevoEstado;
                break;
            }
        }

        emit EstadoActualizado(_proyectoId, _indice, _nuevoEstado);
    }
}

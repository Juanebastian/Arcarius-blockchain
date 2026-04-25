# ARCARIUS — Blockchain

Módulo blockchain del proyecto **ARCARIUS**. Implementa un contrato inteligente en Solidity para el **registro inmutable de documentos de proyectos** (actas, contratos, facturas, informes, soportes) usando Hardhat como entorno de desarrollo.

Cada documento se almacena en la cadena con su CID (referencia a IPFS u otro almacenamiento), su hash, el proyecto al que pertenece, su tipo, versión, estado y autor. Esto permite verificar autenticidad, trazabilidad y versionado de los documentos sin depender de una autoridad central.

---

## Arquitectura

```
ARCARIUS/
├── blockchain/                ← este repositorio
│   ├── contracts/             ← contratos Solidity
│   ├── scripts/               ← despliegue y utilidades
│   ├── ignition/modules/      ← módulos de Hardhat Ignition
│   ├── test/                  ← pruebas
│   └── artifacts/             ← compilados (generados)
└── backend/
    └── src/abi/               ← ABI copiado automáticamente al compilar
```

El contrato principal es [`ProyectoDocumentos`](contracts/ProyectoDocumentos.sol). Al compilar, el script [scripts/copy-abi.js](scripts/copy-abi.js) copia el ABI a `../backend/src/abi/ProyectoDocumentos.json` para que el backend pueda interactuar con el contrato vía `ethers.js`.

---

## Requisitos previos

- **Node.js** ≥ 18
- **npm** ≥ 9
- Sistema operativo: Linux, macOS o Windows con WSL

---

## Instalación

```bash
git clone <repo-url>
cd blockchain
npm install
```

---

## Uso

### 1. Compilar contratos

```bash
npm run compile
```

Compila los contratos en [contracts/](contracts/) y copia el ABI a la carpeta del backend.

### 2. Levantar un nodo local de blockchain

En una **terminal dedicada** (déjala abierta):

```bash
npx hardhat node
```

Esto inicia una red Ethereum local en `http://127.0.0.1:8545` con cuentas de prueba precargadas.

### 3. Desplegar el contrato

En **otra terminal**:

```bash
npx hardhat run scripts/deploy.js --network localhost
```

La consola imprimirá la dirección del contrato desplegado. Guárdala — el backend la necesita para conectarse.

### Otros comandos útiles

```bash
npx hardhat test                                          # ejecuta las pruebas
npx hardhat ignition deploy ./ignition/modules/Lock.js   # despliegue alternativo con Ignition
npx hardhat help                                         # ayuda completa
REPORT_GAS=true npx hardhat test                         # mide consumo de gas
```

---

## Estructura del proyecto

| Carpeta / archivo | Propósito |
|---|---|
| [contracts/](contracts/) | Contratos Solidity (`ProyectoDocumentos.sol`, `Lock.sol`) |
| [scripts/deploy.js](scripts/deploy.js) | Script de despliegue de `ProyectoDocumentos` |
| [scripts/copy-abi.js](scripts/copy-abi.js) | Copia el ABI al backend tras compilar |
| [ignition/modules/](ignition/modules/) | Módulos para Hardhat Ignition |
| [test/](test/) | Pruebas de los contratos |
| [hardhat.config.js](hardhat.config.js) | Configuración de Hardhat (Solidity 0.8.28, redes) |
| `artifacts/`, `cache/` | Salidas de compilación (no versionar) |

---

## Contrato `ProyectoDocumentos`

### Estructura del documento

```solidity
struct Documento {
    string cid;              // referencia al archivo (ej: IPFS)
    bytes32 hashArchivo;     // hash de integridad
    uint256 proyectoId;      // ID del proyecto al que pertenece
    TipoDocumento tipoDocumento;
    uint256 version;
    EstadoDocumento estado;
    address autor;           // wallet que registró el documento
    uint256 timestamp;
}
```

### Enums

- `TipoDocumento`: `Otro`, `Acta`, `Contrato`, `Factura`, `Informe`, `Soporte`
- `EstadoDocumento`: `Vigente`, `Anulado`, `Reemplazado`

### Funciones públicas

| Función | Descripción |
|---|---|
| `guardarDocumento(cid, hashArchivo, proyectoId, tipoDocumento, version)` | Registra un nuevo documento. Solo el `msg.sender` queda como autor. |
| `obtenerMisDocumentos()` | Devuelve todos los documentos registrados por la wallet que llama. |
| `obtenerDocumentosPorProyecto(proyectoId)` | Devuelve todos los documentos asociados a un proyecto. |
| `actualizarEstado(proyectoId, indice, nuevoEstado)` | Cambia el estado de un documento. Solo el autor puede modificarlo. |

### Eventos

- `DocumentoGuardado(autor, proyectoId, cid, hashArchivo, tipoDocumento, version, timestamp)`
- `EstadoActualizado(proyectoId, indice, nuevoEstado)`

---

## Variables de entorno

El proyecto utiliza un archivo `.env` en la raíz. Copia y ajusta según tu entorno:

```bash
# .env (ejemplo)
PRIVATE_KEY=0x...           # llave privada para despliegues en testnet/mainnet
RPC_URL=http://127.0.0.1:8545
```

> ⚠️ Nunca subas `.env` al repositorio. Ya está incluido en `.gitignore`.

---

## Troubleshooting

### `Error: listen EADDRINUSE: address already in use 127.0.0.1:8545`

El puerto 8545 ya está siendo usado, normalmente por un nodo de Hardhat anterior.

```bash
# Identifica el proceso
lsof -i :8545

# Mátalo (reemplaza <PID>)
kill <PID>
```

Alternativa: si solo necesitas desplegar, reutiliza el nodo existente sin matar nada.

### `❌ No se encontró el artifact en: ...`

Aparece cuando ejecutas `copy-abi.js` antes de compilar. Solución:

```bash
npx hardhat compile
```

### El backend no encuentra el ABI

Verifica que la ruta `../backend/src/abi/` exista relativa a este proyecto (ver [scripts/copy-abi.js](scripts/copy-abi.js#L11-L15)). Si tu backend vive en otra ubicación, ajusta `backendAbiPath`.

---

## Tecnologías

- [Hardhat](https://hardhat.org/) `^2.26.2`
- [Solidity](https://soliditylang.org/) `0.8.28`
- [OpenZeppelin Contracts](https://www.openzeppelin.com/contracts) `^5.4.0`
- [ethers.js](https://docs.ethers.org/) v6
- [dotenv](https://github.com/motdotla/dotenv) `^17.2.2`

---

## Licencia

ISC — ver [contracts/ProyectoDocumentos.sol](contracts/ProyectoDocumentos.sol) (SPDX: MIT para el contrato).

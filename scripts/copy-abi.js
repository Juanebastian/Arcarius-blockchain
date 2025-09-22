// scripts/copy-abi.js
const fs = require('fs');
const path = require('path');

const CONTRACT_NAME = 'ProyectoDocumentos';
const artifactPath = path.join(
  __dirname,
  `../artifacts/contracts/${CONTRACT_NAME}.sol/${CONTRACT_NAME}.json`,
);

const backendAbiPath = path.join(
  __dirname,
  '../../backend/src/abi',
  `${CONTRACT_NAME}.json`,
);

async function main() {
  if (!fs.existsSync(artifactPath)) {
    console.error(`❌ No se encontró el artifact en: ${artifactPath}`);
    process.exit(1);
  }

  const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
  const abiOnly = artifact.abi; // ✅ Solo extraemos el ABI

  // Crear carpeta si no existe
  fs.mkdirSync(path.dirname(backendAbiPath), { recursive: true });

  // Guardar ABI limpio
  fs.writeFileSync(backendAbiPath, JSON.stringify(abiOnly, null, 2));

  console.log(`✅ ABI limpio copiado en: ${backendAbiPath}`);
}

main();

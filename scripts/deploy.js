// scripts/deploy.js

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Desplegando con:", deployer.address);

  const Registry = await ethers.getContractFactory("ProyectoDocumentos");
  const registry = await Registry.deploy();

  // En ethers v6 debes usar .waitForDeployment()
  await registry.waitForDeployment();

  console.log("Contrato desplegado en:", await registry.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

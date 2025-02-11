import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const deployed = await deploy("FHEMinesweeper", {
    from: deployer,
    args: [], // No constructor arguments
    log: true,
  });

  console.log(`FHEMinesweeper contract deployed at: `, deployed.address);
};

export default func;
func.id = "deploy_fhe_minesweeper"; // id required to prevent reexecution
func.tags = ["FHEMinesweeper"];

// function deployFunc() {
//     console.log("Deploying FundMe...")
// }

const { network } = require("hardhat")

// module.exports = deployFunc

module.exports = async ({ deployments, getNamedAccounts }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
}

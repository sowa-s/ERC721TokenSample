var SNFT = artifacts.require("./SNFT.sol");

module.exports = function(deployer) {
    deployer.deploy(SNFT);
}
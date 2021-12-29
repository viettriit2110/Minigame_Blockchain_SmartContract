const game = artifacts.require("Game");

module.exports = function (deployer) {
  deployer.deploy(game);
};

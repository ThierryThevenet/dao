var Freelancer = artifacts.require('./contracts/freelancer/Freelancer.sol');
var crypto = require('crypto');
var cryptoPrice = require('crypto-price');

var ethPrice;
var cost;

contract('Freelancer', function(accounts) {

  before( () => {
    return cryptoPrice.getCryptoPrice('EUR', 'ETH').then( (result) => {
      ethPrice = result.price;
    });
  });

  beforeEach( () => {
    cost = 0;
  });

  it('should check that the freelancer/account#1 can join the DAO', function() {
    var contract;
    return Freelancer.deployed().then(function(instance) {
      contract = instance;
      return contract.joinDao({from: accounts[1]});
    }).then(function(result) {
      cost = ((web3.fromWei((result.receipt.gasUsed) * (web3.eth.gasPrice), 'ether')) * ethPrice).toFixed(2);
    }).then(function() {
      return contract.isFreelancerActive.call(accounts[1]);
    }).then(function(isFreelancerActive) {
      assert.equal(isFreelancerActive, true, 'The freelancer/account#1 could not join the DAO');
    });
  });

  it('should check that the freelancer/account#2 can join the DAO through the marketplace/account#3', function() {
    var contract;
    var userHash = crypto.randomBytes(32).toString('hex');
    return Freelancer.deployed().then(function(instance) {
      contract = instance;
      return contract.joinDaoFromMarketplace(accounts[2], userHash, {from: accounts[2]});
    }).then(function(result) {
      cost = ((web3.fromWei((result.receipt.gasUsed) * (web3.eth.gasPrice), 'ether')) * ethPrice).toFixed(2);
    }).then(function() {
      return contract.isFreelancerActive.call(accounts[2]);
    }).then(function(isFreelancerActive) {
      assert.equal(isFreelancerActive, true, 'The freelancer/account#2 could not join the DAO through the marketplace/account#3');
    }).then(function() {
      return contract.marketplacesAccounts.call(userHash);
    }).then(function(address) {
      assert.equal(address, accounts[2], 'The user hash submitted when freelancer/account#2 joined the DAO through the marketplace/account#3 is not mapped to the freelancer/account#2 address');
    });
  });

  afterEach( () => {
    console.log('Cost: ' + cost + '€');
  });

});

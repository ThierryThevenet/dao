var VaultFactory = artifacts.require('VaultFactory');
var Vault = artifacts.require('Vault');
var TalaoToken = artifacts.require('TalaoToken');


contract('Vault', function(accounts) {
    var token, factory, vault;

    before(async function() {
        // deploy token & mint all accounts
        token = await TalaoToken.new({from: accounts[0]});
        for (let acc of accounts) {
            await token.mint(acc, 10e18, {from: accounts[0]});
        }

        await token.finishMinting({from: accounts[0]});
        await token.setVaultDeposit(5e18, {from: accounts[0]});

        // deploy VaultFactory with token address & create new vault
        factory = await VaultFactory.new(token.address, {from: accounts[0]});
    });

    it('should create a vault on demand', async function() {
        // firstly create vault access with price of 3e18 tokens
        await token.createVaultAccess(3e18, {from: accounts[1]});

        // create vault for the same account as above
        let addr = await factory.CreateVaultContract({from: accounts[1]});
        vault = Vault.at(addr.logs[0].address);
        assert.equal(await vault.owner.call(), accounts[1], "owner of vault isnt creator");
    });

    it('should create a document on demand', async function() {
        await vault.addDocument("docid", "description", "keyword", {from: accounts[1]});
        assert(await vault.getDocumentIsAlive.call("docid", {from: accounts[1]}), "document should be alive");
    });
});

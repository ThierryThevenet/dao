var VaultFactory = artifacts.require('VaultFactory');
var Vault = artifacts.require('Vault');
var TalaoToken = artifacts.require('TalaoToken');


contract('Vault', function(accounts) {
    var token, factory, vault;
    var talent = accounts[1];

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
        await token.createVaultAccess(3e18, {from: talent});

        // create vault for the same account as above
        let addr = await factory.CreateVaultContract({from: talent});
        vault = Vault.at(addr.logs[0].address);
        assert.equal(await vault.owner.call(), talent, "owner of vault isnt creator");
    });

    it('should create a document on demand', async function() {
        await vault.addDocument("docid", "description", "keyword", {from: talent});
        assert(await vault.getDocumentIsAlive.call("docid", {from: talent}), "document should be alive");
    });

    it('should add a keyword successfully', async function() {
        await vault.addKeyword("docid", "otherkeyword", {from: talent});
        let keyw = await vault.getKeywordsByIndex("docid", 1, {from: talent});
        assert(web3.toAscii(keyw).startsWith("otherkeyword"), "added wrong keyword?");
    });

    it('should return the correct amount of keywords', async function() {
        let num = await vault.getKeywordsNumber("docid", {from: talent});
        assert.equal(num.toNumber(), 2, "returned wrong number of keywords");
    });
});

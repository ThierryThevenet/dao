# Talao DAO prototype

*Important: the latest code for the Talao Token, and the crowdsale, are in the [Blockchain Partner's repo](https://github.com/Blockchainpartner/talao-crowdsale), not here.*

Based on https://github.com/facebook/create-react-app

## tl;dr

    git clone git@github.com:TalaoDAO/dao.git
    cd dao
    npm install
    cp .env.development .env.development.local
    sed -i 's/HOST=dev.talao.io/HOST=localhost/g' .env.development.local
    npm run start

You are now running a local dev server of Talao DAO, connected to the Ropsten network.
If it didn't open a browser tab automatically, go to : http://localhost:3000

## Using a local dev blockchain

Using a persistent local dev blockchain can be convenient for the interface development.

    cp .env.development .env.development.local

Edit .env.development.local
+ Change the contracts addresses for the ones you have deployed on your local dev BC
+ Change ABIs too if you are developing on the Smart contracts

### Parity local dev blockchain

We use Parity local dev blockchain a lot, because it's persistent nature and tools are real usefull to us. If you want to use it as well:

In a shell, open Parity with Parity UI:

    parity ui --chain=dev --unsafe-expose --datadir ./data/parity

Leave that shell open with the BC running. Go to Parity UI, create a few accounts including an "Admin" account who will be the Smart Contracts owner. Compile and deploy the contracts in /contracts.

Update the adresses and if necessary the ABIs in /.env.development.local

To deploy the TALAO token contract you must add the other Solidity contracts it depends upon. You can import them in Parity. The order of dependencies is:

+ ERC20Basic.sol
+ SafeMath.sol
+ BasicToken.sol
+ ERC20.sol
+ StandardToken.sol
+ Ownable.sol
+ MintableToken.sol
+ TalaoToken.sol

... Or just use TalaoTokenMonolithic.sol

## Smart contracts tests

You must have Truffle installed globaly:

    npm install -g truffle

Launch the Truffle develop console

    truffle develop

Inside of the Truffle develop console, launch the tests:

    test

## Contributing

+ See [CONTRIBUTING.md](https://github.com/TalaoDAO/dao/blob/dev/CONTRIBUTING.md)
+ See [TODO.md](https://github.com/TalaoDAO/dao/blob/dev/TODO.md)

pragma solidity ^0.4.21;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

/**
 * @title TalaoCrowdsale
 * @dev This contract details the TALAO token and allows freelancers to create/revoke vault access, appoint agents.
 *      This contract also implements a marketplace to buy and sell on-chain TALAO tokens.
 * @author Blockchain Partner
 */
contract TalaoToken is MintableToken {
  using SafeMath for uint256;

  // token details
  string public constant name = "Talao";
  string public constant symbol = "TALAO";
  uint8 public constant decimals = 18;

  // vault details
  uint256 public vaultDeposit;
  uint256 public totalDeposit;

  struct FreelanceData {
      uint256 accessPrice;
      address appointedAgent;
      uint sharingPlan;
      uint256 userDeposit;
  }

  struct ClientAccess {
      bool clientAgreement;
      uint clientDate;
  }

  struct MarketplaceData {
    uint buyPrice;
    uint sellPrice;
    uint unitPrice;
  }

  // Vault allowance client x freelancer
  mapping (address => mapping (address => ClientAccess)) public AccessAllowance;

  // Freelance data is public
  mapping (address=>FreelanceData) public Data;

  //MarketplaceData
  MarketplaceData public marketplace;

  // balance eligible for refunds
  uint256 public minBalanceForAccounts;

  // Those event notifies UI about vaults action with msg code
  // msg = 0 Vault access closed
  // msg = 1 Vault access created
  // msg = 2 Vault access price too high
  // msg = 3 not enough tokens to pay deposit
  // msg = 4 agent removed
  // msg = 5 new agent appointed
  // msg = 6 vault access granted to client
  // msg = 7 client not enough token to pay vault access
  event Vault(address indexed client, address indexed freelance, uint msg);
  event SellingPrice(uint sellingPrice);
  event TalaoBought(address buyer, uint amount, uint price, uint unitPrice);
  event TalaoSold(address seller, uint amount, uint price, uint unitPrice);

  modifier onlyMintingFinished()
  {
      require(mintingFinished == true);
      _;
  }

  function TalaoToken()
      public
  {
      setMinBalance(5000000000000000 wei);
  }

  /**
  * @dev Same ERC20 behavior, but require the token to be unlocked
  * @param _spender address The address that will spend the funds.
  * @param _value uint256 The amount of tokens to be spent.
  **/
  function approve(address _spender, uint256 _value)
      public
      onlyMintingFinished
      returns (bool)
  {
      return super.approve(_spender, _value);
  }

  /**
  * @dev Same ERC20 behavior, but require the token to be unlocked and sells some tokens to refill ether balance up to minBalanceForAccounts
  * @param _to address The address to transfer to.
  * @param _value uint256 The amount to be transferred.
  **/
  function transfer(address _to, uint256 _value)
      public
      onlyMintingFinished
      returns (bool result)
  {
      result = super.transfer(_to, _value);
      if((msg.sender.balance <= minBalanceForAccounts) && result) {
        uint amount = minBalanceForAccounts.sub(msg.sender.balance).mul(marketplace.unitPrice).div(marketplace.sellPrice);
        require(balanceOf(msg.sender) >= amount);
        super.transfer(this, amount);
        uint revenue = amount.mul(marketplace.sellPrice).div(marketplace.unitPrice);
        msg.sender.transfer(revenue);
      }
      return result;
  }

  /**
  * @dev Same ERC20 behavior, but require the token to be unlocked
  * @param _from address The address which you want to send tokens from.
  * @param _to address The address which you want to transfer to.
  * @param _value uint256 the amount of tokens to be transferred.
  **/
  function transferFrom(address _from, address _to, uint256 _value)
      public
      onlyMintingFinished
      returns (bool)
  {
      return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Set allowance for other address and notify
   *      Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
   * @param _spender The address authorized to spend
   * @param _value the max amount they can spend
   * @param _extraData some extra information to send to the approved contract
   */
  function approveAndCall(address _spender, uint256 _value, bytes _extraData)
      public
      onlyMintingFinished
      returns (bool)
  {
      tokenRecipient spender = tokenRecipient(_spender);
      if (approve(_spender, _value)) {
          spender.receiveApproval(msg.sender, _value, this, _extraData);
          return true;
      }
  }

  /**
   * @dev Set the balance eligible for refills
   * @param weis the balance in weis
   */
  function setMinBalance(uint256 weis)
      public
      onlyOwner
  {
      minBalanceForAccounts = weis;
  }

  /**
  * @dev Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
  * @param newSellPrice price the users can sell to the contract
  * @param newBuyPrice price users can buy from the contract
  * @param newUnitPrice to manage decimal issue 0,35 = 35 /100 (100 is unit)
  */
  function setPrices(uint256 newSellPrice, uint256 newBuyPrice, uint256 newUnitPrice)
      public
      onlyOwner
  {
      require (newSellPrice > 0 && newBuyPrice > 0 && newUnitPrice > 0);
      marketplace.sellPrice = newSellPrice;
      marketplace.buyPrice = newBuyPrice;
      marketplace.unitPrice = newUnitPrice;
  }

  /**
  * @dev Allow anyone to buy tokens against ether, depending on the buyPrice set by the contract owner.
  * @return amount the amount of tokens bought
  **/
  function buy()
      public
      payable
      onlyMintingFinished
      returns (uint amount)
  {
      amount = msg.value.mul(marketplace.unitPrice).div(marketplace.buyPrice);
      require(balanceOf(this).sub(totalDeposit) >= amount);
      _transfer(this, msg.sender, amount);
      emit TalaoBought(msg.sender, amount, marketplace.buyPrice, marketplace.unitPrice);
      return amount;
  }

  /**
  * @dev Allow anyone to sell tokens for ether, depending on the sellPrice set by the contract owner.
  * @param amount the number of tokens to be sold
  * @return revenue ethers sent in return
  **/
  function sell(uint amount)
      public
      onlyMintingFinished
      returns (uint revenue)
  {
      require(balanceOf(msg.sender) >= amount);
      super.transfer(this, amount);
      revenue = amount.mul(marketplace.sellPrice).div(marketplace.unitPrice);
      msg.sender.transfer(revenue);
      emit TalaoSold(msg.sender, amount, marketplace.sellPrice, marketplace.unitPrice);
      return revenue;
  }

  /**
   * @dev Allows the owner to withdraw ethers from the contract.
   * @param ethers quantity of ethers to be withdrawn
   * @return true if withdrawal successful ; false otherwise
   */
  function withdrawEther(uint256 ethers)
      public
      onlyOwner
  {
      if (this.balance >= ethers) {
          msg.sender.transfer(ethers);
      }
  }

  /**
   * @dev Allow the owner to withdraw tokens from the contract without taking tokens from deposits.
   * @param tokens quantity of tokens to be withdrawn
   */
  function withdrawTalao(uint256 tokens)
      public
      onlyOwner
  {
      require(balanceOf(this).sub(totalDeposit) >= tokens);
      _transfer(this, msg.sender, tokens);
  }

  /******************************************/
  /*      vault functions start here        */
  /******************************************/

  /**
  * @dev Allows anyone to create a vault access.
  *      Vault is setup in another contract
  *      Vault deposit is transferred to token contract and sum is stored in totalDeposit
  *      Price must be lower than Vault deposit
  * @param price to pay to access certificate vault
  */
  function createVaultAccess (uint256 price)
      public
      onlyMintingFinished
  {
      require(AccessAllowance[msg.sender][msg.sender].clientAgreement==false);
      if (price>vaultDeposit) {
          emit Vault(msg.sender, msg.sender, 2);
          return;
      }
      if (balanceOf(msg.sender)<vaultDeposit) {
          emit Vault(msg.sender, msg.sender,3);
          return;
      }
      Data[msg.sender].accessPrice=price;
      super.transfer(this, vaultDeposit);
      totalDeposit = totalDeposit.add(vaultDeposit);
      Data[msg.sender].userDeposit=vaultDeposit;
      Data[msg.sender].sharingPlan=100;
      AccessAllowance[msg.sender][msg.sender].clientAgreement=true;
      emit Vault(msg.sender, msg.sender, 1);
  }

  /**
  * @dev Closes a vault access, deposit is sent back to freelance wallet
  *      Total deposit in token contract is reduced by user deposit
  */
  function closeVaultAccess()
      public
      onlyMintingFinished
  {
      require(AccessAllowance[msg.sender][msg.sender].clientAgreement==true);
      require(_transfer(this, msg.sender, Data[msg.sender].userDeposit));
      AccessAllowance[msg.sender][msg.sender].clientAgreement=false;
      totalDeposit=totalDeposit.sub(Data[msg.sender].userDeposit);
      Data[msg.sender].sharingPlan=0;
      emit Vault(msg.sender, msg.sender, 0);
  }

  /**
  * @dev Internal transfer function used to transfer tokens from an address to another without prior authorization.
  *      Only used in these situations:
  *           * Send tokens from the contract to a token buyer (buy() function)
  *           * Send tokens from the contract to the owner in order to withdraw tokens (withdrawTalao(tokens) function)
  *           * Send tokens from the contract to a user closing its vault thus claiming its deposit back (closeVaultAccess() function)
  * @param _from address The address which you want to send tokens from.
  * @param _to address The address which you want to transfer to.
  * @param _value uint256 the amount of tokens to be transferred.
  * @return true if transfer is successful ; should throw otherwise
  */
  function _transfer(address _from, address _to, uint _value)
      internal
      returns (bool)
  {
      require(_to != 0x0);
      require(balances[_from] >= _value);
      require((balances[_to].add(_value)) > balances[_to]);

      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      emit Transfer(_from, _to, _value);
      return true;
  }

  /**
  * @dev Appoint an agent or a new agent
  *      Former agent is replaced by new agent
  *      Agent will receive token on behalf of the freelance talent
  * @param newagent agent to appoint
  * @param newplan sharing plan is %, 100 means 100% for freelance
  */
  function agentApproval (address newagent, uint newplan)
      public
      onlyMintingFinished
  {
      require(newplan<=100);
      require(AccessAllowance[msg.sender][msg.sender].clientAgreement==true);
      AccessAllowance[Data[msg.sender].appointedAgent][msg.sender].clientAgreement=false;
      emit Vault(Data[msg.sender].appointedAgent, msg.sender, 4);
      Data[msg.sender].appointedAgent=newagent;
      Data[msg.sender].sharingPlan=newplan;
      AccessAllowance[newagent][msg.sender].clientAgreement=true;
      emit Vault(newagent, msg.sender, 5);
  }

  /**
   * @dev Set the quantity of tokens necessary for vault access creation
   * @param newdeposit deposit (in tokens) for vault access creation
   */
  function setVaultDeposit (uint newdeposit)
      public
      onlyOwner
  {
      vaultDeposit = newdeposit;
  }

  /**
  * @dev Buy unlimited access to a freelancer vault
  *      Vault access price is transfered from client to agent or freelance depending on the sharing plan
  *      Allowance is given to client and one stores block.number for future use
  * @param freelance the address of the talent
  * @return true if access is granted ; false if not
  */
  function getVaultAccess (address freelance)
      public
      onlyMintingFinished
      returns (bool)
  {
      require(AccessAllowance[freelance][freelance].clientAgreement==true);
      require(AccessAllowance[msg.sender][freelance].clientAgreement!=true);
      if (balanceOf(msg.sender)<Data[freelance].accessPrice){
          emit Vault(msg.sender, freelance, 7);
          return false;
      }
      uint256 freelance_share = Data[freelance].accessPrice.mul(Data[freelance].sharingPlan).div(100);
      uint256 agent_share = Data[freelance].accessPrice.sub(freelance_share);
      super.transfer(freelance, freelance_share);
      super.transfer(Data[freelance].appointedAgent, agent_share);
      AccessAllowance[msg.sender][freelance].clientAgreement=true;
      AccessAllowance[msg.sender][freelance].clientDate=block.number;
      emit Vault(msg.sender, freelance, 6);
      return true;
  }

  /**
  * @dev Simple getter to retrieve talent agent
  * @param freelance talent address
  * @return address of the agent
  **/
  function getFreelanceAgent(address freelance)
      public
      view
      returns (address)
  {
      return Data[freelance].appointedAgent;
  }

  /**
  * @dev Fallback function ; only owner can send ether for marketplace purposes.
  **/
  function ()
      public
      payable
      onlyOwner
  {

  }

}


/**
 * @title Freelancer
 * @dev This contract details a TALAO freelancer.
 * @author Talao
 */
contract Freelancer is Ownable {
    using SafeMath for uint256;

    struct FreelancerInformation {
        // Active freelancer?
        bool isActive;
        // Blocked freelancer?
        bool isBlocked;
    }

    struct FreelancerCommunityReputation {
        // Ratings by the clients within a community.
        uint[4] clientsRatings;
        // Clients ratings weights within a community.
        uint[4] clientsRatingsWeights;
        // Pointer to loop through clients ratings and always keep 4. From 0 to 3.
        uint clientsRatingsPointer;
        // Community contribution score of the freelancer.
        // uint is needed, int functions not yet in SafeMath
        // @see https://github.com/OpenZeppelin/zeppelin-solidity/pull/835
        uint contributionScore;
        // Block number of the latest community contribution score update, to compute decay (reputation decreases with time).
        uint lastContributionBlock;
    }

    // Owner of the contract.
    address owner;
    // Number of blocks in a Quarter.
    uint blocksPerQuarter;
    // Freelancers information.
    mapping(address => FreelancerInformation) private freelancerInformation;
    // Freelancers reputation by community. Freelancer address => (Community address => Reputation).
    mapping(address => mapping(address => FreelancerCommunityReputation)) private freelancerCommunityReputation;
    // Mapping of Marketplace user hashes => Freelancer Ethereum addresses.
    mapping(bytes32 => address) public marketplacesAccounts;

    // Event: a freelancer subscribed.
    event FreelancerSubscribed(address indexed _freelancerAddress);
    // Event: a freelancer subscribed from a Marketplace.
    event FreelancerSubscribedFromMarketPlace(
        address indexed _freelancerAddress,
        address indexed _marketplaceAddress,
        bytes32 indexed _marketplaceUserHash
    );
    // Event: a freelancer has a new client rating, within a community.
    event FreelancerNewClientRating(
        address indexed _freelancerAddress,
        address indexed _communityAddress,
        uint _clientRating,
        uint _clientRatingWeight
    );
    event FreelancerNewContribution(
        address indexed _freelancerAddress,
        address indexed _communityAddress,
        uint _contributionValue
    );

    /**
    * @dev Init owner and delay for decay calculation.
    **/
    function Freelancer()
        public
    {
        // Owner = contract creator.
        owner = msg.sender;
        // 60s / 15blocks * 60min * 24h * 30d * 3months = 518400 blocks / quarter.
        blocksPerQuarter = 518400;
    }

    /**
    * @dev Join the DAO.
    **/
    function joinDao()
        public
    {
        // The user Ethereum address must not exist in the registry.
        require(freelancerInformation[msg.sender].isActive == false);
        // The user Ethereum address must not be blocked in the registry.
        require(freelancerInformation[msg.sender].isBlocked == false);

        freelancerInformation[msg.sender].isActive = true;

        emit FreelancerSubscribed(msg.sender);
    }

    /**
    * @dev Join the DAO from a Marketplace.
    * @param _marketplaceAddress The Marketplace Ethereum address.
    * @param _marketplaceUserHash The Marketplace can submit a unique hash by user.
    **/
    function joinDaoFromMarketplace(address _marketplaceAddress, bytes32 _marketplaceUserHash)
        public
    {
        // Marketplace Ethereum address can't be empty.
        require (_marketplaceAddress != address(0x0));
        // Marketplace user hash must be 32 bytes.
        require (_marketplaceUserHash.length == 32);
        // Marketplace user hash must not already exist.
        require(marketplacesAccounts[_marketplaceUserHash] == 0);

        joinDao();

        marketplacesAccounts[_marketplaceUserHash] = msg.sender;

        emit FreelancerSubscribedFromMarketPlace(msg.sender, _marketplaceAddress, _marketplaceUserHash);
    }

    /**
    * @dev Register a client rating for the freelancer, within a community.
    * @param _freelancerAddress address The freelancer Ethereum address.
    * @param _communityAddress address The community Ethereum address.
    * @param _clientRating uint The client rating. From 1 to 50.
    * @param _clientRatingWeight uint The client rating weight. From 1 to 5.
    **/
    function registerClientRating(
        address _freelancerAddress,
        address _communityAddress,
        uint _clientRating,
        uint _clientRatingWeight
    )
        public
    {
        // Freelancer must be active.
        require(freelancerInformation[_freelancerAddress].isActive == true);
        // Community Ethereum address can't be empty.
        require (_communityAddress != address(0x0));
        // Client rating must be between 1 and 50.
        require(_clientRating > 0 && _clientRating <= 50);
        // Client rating weight must be between 1 and 5.
        require(_clientRatingWeight > 0 && _clientRatingWeight <= 5);

        FreelancerCommunityReputation storage reputation = freelancerCommunityReputation[_freelancerAddress][_communityAddress];

        reputation.clientsRatings[reputation.clientsRatingsPointer] = _clientRating;
        reputation.clientsRatingsWeights[reputation.clientsRatingsPointer] = _clientRatingWeight;

        // 4 client Ratings by freelancer & community at maximum. If more, we replace the older ones.
        if (reputation.clientsRatingsPointer == 3) {
          reputation.clientsRatingsPointer = 0;
        }
        // Increase pointer for the next client rating.
        else {
          reputation.clientsRatingsPointer.add(1);
        }

        emit FreelancerNewClientRating(_freelancerAddress, _communityAddress, _clientRating, _clientRatingWeight);
    }

    /**
    * @dev Register a community contribution for the freelancer.
    * @param _freelancerAddress address The freelancer Ethereum address.
    * @param _communityAddress address The community Ethereum address.
    * @param _contributionValue uint The contribution value. From 1 (least important) to 10 (most important).
    **/
    function registerCommunityContribution(
        address _freelancerAddress,
        address _communityAddress,
        uint _contributionValue
    )
        public
    {
        // Freelancer must be active.
        require(freelancerInformation[_freelancerAddress].isActive == true);
        // Community Ethereum address can't be empty.
        require (_communityAddress != address(0x0));
        // Contribution value must be between 1 (least important) to 10 (most important).
        require(_contributionValue > 0 && _contributionValue <= 10);

        FreelancerCommunityReputation storage reputation = freelancerCommunityReputation[_freelancerAddress][_communityAddress];

        // Decay of the contribution score with time (basic implementation).
        // For now, in a Quarter without any new contribution registration, the freelance loses all his previous contribution score.
        // It is gradual, but can be abused in different ways, so this needs more work.
        uint blocksSinceLastCommunityContributionRegistration = (block.number).sub(reputation.lastContributionBlock);
        // We can't store floating numbers, so before dividing, we multiply by 100 temporarily.
        uint blocksSinceLastCommunityContributionRegistrationMultipliedByOneHundred = blocksSinceLastCommunityContributionRegistration.mul(100);
        uint decayMultipliedByOneHundred = blocksSinceLastCommunityContributionRegistrationMultipliedByOneHundred.div(blocksPerQuarter);
        uint lostContributionScoreMultipliedByOneHundred = (reputation.contributionScore).mul(decayMultipliedByOneHundred);
        // Final lost contribution score.
        uint lostContributionScore = lostContributionScoreMultipliedByOneHundred.div(100);
        // If more than one Quarter elapsed, loose all (to avoid negative results).
        if (lostContributionScore > reputation.contributionScore) {
          reputation.contributionScore = 0;
        }
        // Else loose just the lost contribution score.
        else {
          (reputation.contributionScore).sub(lostContributionScore);
        }

        // Add new contribution value to the contribution score.
        reputation.contributionScore = (reputation.contributionScore).add(_contributionValue);
        // Max contribution score is 50.
        if (reputation.contributionScore > 50) {
            reputation.contributionScore = 50;
        }

        // Update the last contribution block number, to compute the decay in the next contribution registration.
        reputation.lastContributionBlock = block.number;

        emit FreelancerNewContribution(_freelancerAddress, _communityAddress, _contributionValue);
    }

    /**
    * @dev Checks if the freelancer is active in the DAO.
    * @param _freelancerAddress address Address of the freelance.
    **/
    function isFreelancerActive(address _freelancerAddress)
        constant
        public
        returns (bool freelancerIsActive)
    {
        freelancerIsActive = freelancerInformation[_freelancerAddress].isActive;
    }

    /**
    * @dev Get infos on the freelancer to compute his vote weight within one community.
    * @param _freelancerAddress address Address of the freelance.
    * @param _communityAddress uint256 Address of the community.
    **/
    function getFreelancerVoteWeight(address _freelancerAddress, address _communityAddress)
        constant
        public
        returns (bool freelancerIsActive, uint freelancerContributionRating, uint freelancerClientsRatings)
    {
        freelancerIsActive = freelancerInformation[_freelancerAddress].isActive;
        if (freelancerIsActive == false) {
            return (false, 0, 0);
        }
        FreelancerCommunityReputation memory reputation = freelancerCommunityReputation[_freelancerAddress][_communityAddress];
        freelancerContributionRating = reputation.contributionScore;
        for (uint i = 0; i < reputation.clientsRatings.length; i++) {
            uint freelancerClientRating = (reputation.clientsRatingsWeights[i]).mul(reputation.clientsRatings[i]);
            freelancerClientsRatings = freelancerClientsRatings.add(freelancerClientRating);
        }
    }

    /**
    * @dev Block a Freelancer Ethereum address.
    * @param _freelancerAddress address The freelancer Ethereum address to block.
    **/
    function blockFreelancer(address _freelancerAddress)
        public
        onlyOwner
    {
        // User must be active.
        require(freelancerInformation[_freelancerAddress].isActive == true);
        // User must not be blocked.
        require(freelancerInformation[_freelancerAddress].isBlocked == false);

        freelancerInformation[_freelancerAddress].isActive = false;
        freelancerInformation[_freelancerAddress].isBlocked = true;
    }

    /**
    * @dev Unblock a Freelancer Ethereum address.
    * @param _freelancerAddress address The freelancer Ethereum address to unblock.
    **/
    function unblockFreelancer(address _freelancerAddress)
        public
        onlyOwner
    {
        // User must not be active.
        require(freelancerInformation[_freelancerAddress].isActive == false);
        // User must be blocked.
        require(freelancerInformation[_freelancerAddress].isBlocked == true);

        freelancerInformation[_freelancerAddress].isActive = true;
        freelancerInformation[_freelancerAddress].isBlocked = false;
    }
}


/**
 * @title Community
 * @dev This contract details a TALAO community.
 * @author Talao
 */
contract Community is Ownable {

    // Talao token.
    TalaoToken public talaotoken;

    // Freelancer.
    Freelancer public freelancerContract;

    // Community name.
    string public communityName;

    // Active community?
    bool public communityIsActive;

    // Private community?
    bool public communityIsPrivate;

    // Sponsor address if private community.
    address public communitySponsor;

    // Token percentage balance to vote in community (10 = 10% token, 90% reputation). From 1 to 100.
    uint public communityBalanceToVote;

    // Minimum tokens to vote in community. From 1 to 100.
    uint public communityMinimumTokensToVote;

    // Minimum reputation to vote in community. From 1 to 100.
    uint public communityMinimumReputationToVote;

    // (Community commission on job) / 100. 100 means 1%. From 0 to 10000.
    uint public communityJobCommission;

    // Fee to join community.
    uint public communityJoinFee;

    // Community members.
    mapping(address => bool) public communityMembers;

    // For test purposes.
    uint256 public communityTokenBalance;

    // Event: a freelancer joined a community.
    event CommunitySubscription(address indexed _freelancerAddress, address indexed _communityAddress);

    /**
    * @dev Community.
    * @param _token address The address of the Talao token smart contract.
    * @param _freelancerContractAddress address The address of the Freelancer smart contract.
    * @param _name string Community name.
    * @param _isprivate bool Private community?
    * @param _sponsor address Sponsor address if private community.
    * @param _balancetovote uint Token percentage balance to vote in community (10 = 10% token, 90% reputation). From 1 to 100.
    * @param _mintokens uint Minimum tokens to vote in community. > 0
    * @param _minreputation uint Minimum reputation to vote in community. From 1 to 100.
    * @param _jobcommission uint (Community commission on job) / 100. 100 means 1%. From 0 to 10000.
    * @param _joinfee uint Fee to join community.
    **/
    function Community(
        address _token,
        address _freelancerContractAddress,
        string _name,
        bool _isprivate,
        address _sponsor,
        uint _balancetovote,
        uint _mintokens,
        uint _minreputation,
        uint _jobcommission,
        uint _joinfee
    )
        public
    {
        // By default, new communities are active.
        communityIsActive = true;

        // Load smart contract depencencies.
        talaotoken = TalaoToken(_token);
        freelancerContract = Freelancer(_freelancerContractAddress);

        // Community params.
        communityName = _name;
        communityIsPrivate = _isprivate;
        communitySponsor = _sponsor;
        communityBalanceToVote = _balancetovote;
        communityMinimumTokensToVote = _mintokens;
        communityMinimumReputationToVote = _minreputation;
        communityJobCommission = _jobcommission;
        communityJoinFee = _joinfee;

        // For test purposes.
        communityTokenBalance = talaotoken.balanceOf(this);
    }

    /**
    * @dev Community voting rules.
    * @param _balancetovote uint Token percentage balance for voting in community (10 = 10% token, 90% reputation). From 1 to 100.
    * @param _mintokens uint Minimum tokens to vote in community. From 1 to 100.
    * @param _minreputation uint Minimum reputation to vote in community (1 to 100)
    **/
    function setupVotingRules(uint _balancetovote, uint _mintokens, uint _minreputation)
        public onlyOwner
    {
        require (_balancetovote > 0 && _balancetovote <= 100);
        require (_mintokens > 0);
        require (_minreputation > 0 && _minreputation <= 100);
        communityBalanceToVote = _balancetovote;
        communityMinimumTokensToVote = _mintokens;
        communityMinimumReputationToVote = _minreputation;
    }

    /**
    * @dev Join a community.
    **/
    function joinCommunity()
        public
    {
        // To join a community, freelancers must have registred in the DAO.
        require(freelancerContract.isFreelancerActive(msg.sender) == true);

        communityMembers[msg.sender] = true;

        emit CommunitySubscription(msg.sender, this);
    }

    /**
    * @dev Leave a community.
    **/
    function leaveCommunity()
        public
    {
        // Revert if not a member.
        if (!communityMembers[msg.sender]) {
            revert();
        }
        communityMembers[msg.sender] = false;
    }

    /**
    * @dev Transfers tokens from the Community.
    * @param _to address Address to send the tokens to.
    * @param _amount uint256 Amount of tokens to transfer.
    **/
    function transferFunds(address _to, uint256 _amount)
        public onlyOwner
        returns (bool)
    {
        require (_amount <= talaotoken.balanceOf(this));
        talaotoken.transfer(_to, _amount);
        return true;
    }
}


/**
 * @title Community factory.
 * @dev Creates and manages community contracts.
 * @author Talao
 */
contract CommunityFactory is Ownable {

    TalaoToken public talaotoken;
    Freelancer public freelancerContract;

    // Event: a community has been created.
    event CommunityListing (address community);

    /**
    * @dev Community factory.
    * @param _token address The address of the token.
    * @param _freelancerContractAddress The address of the Freelancer smart contract.
    **/
    function CommunityFactory (address _token, address _freelancerContractAddress)
        public
    {
        // Talao token & Freelancer smart contract addresses can't be empty.
        require (_token != address(0x0));
        require (_freelancerContractAddress != address(0x0));

        talaotoken = TalaoToken(_token);
        freelancerContract = Freelancer(_freelancerContractAddress);
    }

    /**
    * @dev Create a community.
    * @param _name string Community name.
    * @param _isprivate bool Private community?
    * @param _sponsor address Sponsor address if private community.
    * @param _balancetovote uint Token percentage balance to vote in community (10 = 10% token, 90% reputation). From 1 to 100.
    * @param _mintokens uint Minimum tokens to vote in community. > 0
    * @param _minreputation uint Minimum reputation to vote in community. From 1 to 100.
    * @param _jobcommission uint (Community commission on job) / 100. 100 means 1%. From 0 to 10000.
    * @param _joinfee uint Fee to join community.
    **/
    function createCommunityContract(
        string _name,
        bool _isprivate,
        address _sponsor,
        uint _balancetovote,
        uint _mintokens,
        uint _minreputation,
        uint _jobcommission,
        uint _joinfee
    )
        public onlyOwner
        returns (Community)
    {
        require (_balancetovote > 0 && _balancetovote <= 100);
        require (_mintokens > 0);
        require (_minreputation > 0 && _minreputation <= 100);
        require (_jobcommission >= 0 && _jobcommission <= 10000);

        Community newcommunity;
        newcommunity = new Community(
            talaotoken,
            freelancerContract,
            _name,
            _isprivate,
            _sponsor,
            _balancetovote,
            _mintokens,
            _minreputation,
            _jobcommission,
            _joinfee
        );
        newcommunity.transferOwnership(msg.sender);

        emit CommunityListing(newcommunity);
        return newcommunity;
    }

    /**
     * @dev Prevents accidental sending of ether to the factory.
     */
    function ()
        public
    {
        revert();
    }
}

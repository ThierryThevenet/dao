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
    uint256 c = a / b;
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
    Transfer(msg.sender, _to, _value);
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
    Transfer(_from, _to, _value);
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
    Approval(msg.sender, _spender, _value);
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
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
    OwnershipTransferred(owner, newOwner);
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
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

/**
 * @title TalaoToken
 * @dev This contract details the TALAO token and allows freelancers to create/revoke vault access, appoint agents.
 * @author Blockchain Partner
 */
contract TalaoToken is MintableToken {
  using SafeMath for uint256;

  // token details
  string public constant name = "Talao";
  string public constant symbol = "TALAO";
  uint8 public constant decimals = 18;

  // the talao marketplace address
  address public marketplace;

  // talao tokens needed to create a vault
  uint256 public vaultDeposit;
  // sum of all talao tokens desposited
  uint256 public totalDeposit;

  struct FreelanceData {
      // access price to the talent vault
      uint256 accessPrice;
      // address of appointed talent agent
      address appointedAgent;
      // how much the talent is sharing with its agent
      uint sharingPlan;
      // how much is the talent deposit
      uint256 userDeposit;
  }

  // structure that defines a client access to a vault
  struct ClientAccess {
      // is he allowed to access the vault
      bool clientAgreement;
      // the block number when access was granted
      uint clientDate;
  }

  // Vault allowance client x freelancer
  mapping (address => mapping (address => ClientAccess)) public accessAllowance;

  // Freelance data is public
  mapping (address=>FreelanceData) public data;

  enum VaultStatus {Closed, Created, PriceTooHigh, NotEnoughTokensDeposited, AgentRemoved, NewAgent, NewAccess, WrongAccessPrice}

  // Those event notifies UI about vaults action with vault status
  // Closed Vault access closed
  // Created Vault access created
  // PriceTooHigh Vault access price too high
  // NotEnoughTokensDeposited not enough tokens to pay deposit
  // AgentRemoved agent removed
  // NewAgent new agent appointed
  // NewAccess vault access granted to client
  // WrongAccessPrice client not enough token to pay vault access
  event Vault(address indexed client, address indexed freelance, VaultStatus status);

  modifier onlyMintingFinished()
  {
      require(mintingFinished == true);
      _;
  }

  /**
  * @dev Let the owner set the marketplace address once minting is over
  *      Possible to do it more than once to ensure maintainability
  * @param theMarketplace the marketplace address
  **/
  function setMarketplace(address theMarketplace)
      public
      onlyMintingFinished
      onlyOwner
  {
      marketplace = theMarketplace;
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
      return super.transfer(_to, _value);
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
   * @dev Allows the owner to withdraw ethers from the contract.
   * @param ethers quantity in weis of ethers to be withdrawn
   * @return true if withdrawal successful ; false otherwise
   */
  function withdrawEther(uint256 ethers)
      public
      onlyOwner
  {
      msg.sender.transfer(ethers);
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
  *      Vault deposit is transferred to token contract and sum is stored in totalDeposit
  *      Price must be lower than Vault deposit
  * @param price to pay to access certificate vault
  */
  function createVaultAccess (uint256 price)
      public
      onlyMintingFinished
  {
      require(accessAllowance[msg.sender][msg.sender].clientAgreement==false);
      if (price>vaultDeposit) {
          Vault(msg.sender, msg.sender, VaultStatus.PriceTooHigh);
          return;
      }
      if (balanceOf(msg.sender)<vaultDeposit) {
          Vault(msg.sender, msg.sender, VaultStatus.NotEnoughTokensDeposited);
          return;
      }
      data[msg.sender].accessPrice=price;
      super.transfer(this, vaultDeposit);
      totalDeposit = totalDeposit.add(vaultDeposit);
      data[msg.sender].userDeposit=vaultDeposit;
      data[msg.sender].sharingPlan=100;
      accessAllowance[msg.sender][msg.sender].clientAgreement=true;
      Vault(msg.sender, msg.sender, VaultStatus.Created);
  }

  /**
  * @dev Closes a vault access, deposit is sent back to freelance wallet
  *      Total deposit in token contract is reduced by user deposit
  */
  function closeVaultAccess()
      public
      onlyMintingFinished
  {
      require(accessAllowance[msg.sender][msg.sender].clientAgreement==true);
      require(_transfer(this, msg.sender, data[msg.sender].userDeposit));
      accessAllowance[msg.sender][msg.sender].clientAgreement=false;
      totalDeposit=totalDeposit.sub(data[msg.sender].userDeposit);
      data[msg.sender].sharingPlan=0;
      Vault(msg.sender, msg.sender, VaultStatus.Closed);
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

      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(_from, _to, _value);
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
      require(accessAllowance[msg.sender][msg.sender].clientAgreement==true);
      Vault(data[msg.sender].appointedAgent, msg.sender, VaultStatus.AgentRemoved);
      data[msg.sender].appointedAgent=newagent;
      data[msg.sender].sharingPlan=newplan;
      Vault(newagent, msg.sender, VaultStatus.NewAgent);
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
      require(accessAllowance[freelance][freelance].clientAgreement==true);
      require(accessAllowance[msg.sender][freelance].clientAgreement!=true);
      if (balanceOf(msg.sender)<data[freelance].accessPrice){
          Vault(msg.sender, freelance, VaultStatus.WrongAccessPrice);
          return false;
      }
      uint256 freelance_share = data[freelance].accessPrice.mul(data[freelance].sharingPlan).div(100);
      uint256 agent_share = data[freelance].accessPrice.sub(freelance_share);
      if(freelance_share>0) super.transfer(freelance, freelance_share);
      if(agent_share>0) super.transfer(data[freelance].appointedAgent, agent_share);
      accessAllowance[msg.sender][freelance].clientAgreement=true;
      accessAllowance[msg.sender][freelance].clientDate=block.number;
      Vault(msg.sender, freelance, VaultStatus.NewAccess);
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
      return data[freelance].appointedAgent;
  }

  /**
  * @dev Simple getter to check if user has access to a freelance vault
  * @param freelance talent address
  * @param user user address
  * @return true if access granted or false if not
  **/
  function hasVaultAccess(address freelance, address user)
      public
      view
      returns (bool)
  {
      return ((accessAllowance[user][freelance].clientAgreement) || (data[freelance].appointedAgent == user));
  }

}


/**
 * @title Vault
 * @dev Vault
 */
contract Vault is Ownable {
    using SafeMath for uint;

    uint NbOfValidDocument;
    TalaoToken myToken;

    struct certifiedDocument {
        bytes32 description; //description of document
        bytes32[] keywords; //list of keywords associated to the current certified document
        bool isAlive; //true if this stuct is set, fasle else
        uint index; //index used in relationship between tabindex and mapping unordered object
    }

    //Used to parse all documents using index as relationship between this array and TalentsDocuments mapping
    bytes32[] documentIndex;

    //address is owner of document
    //Certified
    mapping(bytes32 => certifiedDocument) public talentsDocuments;

    enum VaultLife { AccessDenied, DocumentAdded, DocumentRemoved, keywordAdded }

    event VaultLog (
        address indexed user,
        VaultLife happened,
        bytes32 documentId
    );

    event VaultDocAdded (
        address indexed user,
        bytes32 documentId,
        bytes32 description
    );

    modifier allowance () { //require sur l'aggreement
        bool agreement = false;
        uint unused = 0;
        (agreement, unused) = myToken.AccessAllowance(msg.sender,msg.sender);
        require(agreement == true);
        _;
    }

    /*
    add new certification document to Talent Vault
    accessibility : only for authorized user and owner of this contract
    */
    function Vault(address token)
        public
    {
        myToken = TalaoToken(token);
    }

    /*
    add new certification document to Talent Vault
    accessibility : only for authorized user and owner of this contract
    */
    function addDocument(bytes32 documentId, bytes32 description, bytes32 keyword)
        onlyOwner
        allowance
        public
        returns (bool)
    {
        require(documentId != 0 && keyword.length != 0);
        require(!talentsDocuments[documentId].isAlive);
        NbOfValidDocument = NbOfValidDocument.add(1);

        talentsDocuments[documentId].description = description;
        talentsDocuments[documentId].isAlive = true;
        talentsDocuments[documentId].index = documentIndex.push(documentId)-1;
        talentsDocuments[documentId].keywords.push(keyword);

        emit VaultDocAdded(msg.sender,documentId,description);
        return true;
    }

    /*
    Add keyword to a specified document using document Id
    accessibility : only for authorized user and owner of this contract
    */
    function addKeyword(bytes32 documentId,bytes32 keyword)
        onlyOwner
        allowance
        public
        returns (bool)
    {
        require(documentId != 0 && keyword.length != 0);
        require(talentsDocuments[documentId].isAlive);

        talentsDocuments[documentId].keywords.push(keyword);
        emit VaultLog(msg.sender, VaultLife.keywordAdded, documentId);
        return true;
    }

    /*
    Remove existing document using document id
    accessibility : only for authorized user and owner of this contract
    */
    function removeDocument (bytes32 documentId)
        onlyOwner
        allowance
        public
    {
        require(documentId != 0);
        if(talentsDocuments[documentId].description.length != 0) {
            NbOfValidDocument--;
            delete talentsDocuments[documentId]; //set isValid to false
            assert(talentsDocuments[documentId].isAlive==false);
            emit VaultLog(msg.sender, VaultLife.DocumentRemoved, documentId);
        }
    }

    /*
    get indication to know quickly if document removed or not
    accessibility : only for authorized user
    */
    function getDocumentIsAlive(bytes32 documentId)
        allowance
        constant
        public
        returns(bool)
    {
        require(documentId != 0);
        return(talentsDocuments[documentId].isAlive);
    }

    /*
    get a Keywords number to allow clients to loop on each keywords
    accessibility : only for authorized user
    */
    function getKeywordsNumber(bytes32 documentId)
        allowance
        constant
        public
        returns (uint)
    {
        require(documentId != 0);
        return talentsDocuments[documentId].keywords.length;
    }

    /*
    get a Keywords using index
    accessibility : only for authorized user
    */
    function getKeywordsByIndex(bytes32 documentId, uint index)
        allowance
        constant
        public
        returns (bytes32)
    {
        require(documentId != 0);
        return talentsDocuments[documentId].keywords[index];
    }

    /*
    this method allows the client to retrieve a specific certified document data
    using document Id provided by ethereum when a document is uploaded
    accessibility : only for authorized user
    */
    function getCertifiedDocumentById (bytes32 documentId)
        allowance
        public
        constant
        returns (bytes32 docId, bytes32 desc, uint keywordNumber)
    {
        require(documentId != 0 && talentsDocuments[documentId].isAlive == true);
        return (documentId, talentsDocuments[documentId].description, talentsDocuments[documentId].keywords.length);
    }

    /*
    This method allows the client to retrieve the list of documents (documents by documents) by browsing it with his index
    accessibility : only for authorized user
    */
    function getCertifiedDocumentsByIndex (uint index)
        allowance
        constant
        public
        returns (bytes32 docId, bytes32 desc, uint keywordNumber)
    {
        bytes32 dId = documentIndex[index];
        return (dId, talentsDocuments[dId].description, talentsDocuments[dId].keywords.length);
    }

    /*
    get list of interestng document based on search keyword
    accessibility : only for authorized user
    */
    function getMatchCertifiedDocument (uint index, bytes32 keyword)
        allowance
        constant
        public
        returns(bytes32 docId, bytes32 desc)
    {
        bytes32 dId = documentIndex[index];
        bytes32 valueFounded;
        for (uint i = 0; i < talentsDocuments[dId].keywords.length; i++) {
            valueFounded = talentsDocuments[dId].keywords[i];
            if(keccak256(valueFounded) == keccak256(keyword)){
                return (dId, talentsDocuments[dId].description);
            }
        }
    }

    function ()
        public
    {
        revert();
    }
}


/**
 * @title VaultFactory
 * @dev Vault factory
 */
contract VaultFactory is Ownable {
    uint public nbVault;
    TalaoToken myToken;

    //first address is Talent ethereum address
    //second address is Smart Contract vault address dedicated to this talent
    mapping (address=>address) public FreelanceVault;

    enum VaultState { AccessDenied, AlreadyExist, Created }
    event VaultCreation(address indexed talent, address vaultadddress, VaultState msg);

    //address du smart contract token
    function VaultFactory(address token)
        public
    {
        myToken = TalaoToken(token);
    }

    function getMyToken()
        public
        returns (address)
    {
        SafeMath.add(nbVault,1);
        //require (nbVault >= 0);
        return myToken;
    }

    function getNbVault()
        public
        view
        returns(uint)
    {
        return nbVault;
    }

    /**
     * Talent can call this method to create a new Vault contract
     *  with the maker being the owner of this new vault
     */
    function CreateVaultContract ()
        public
        returns(address)
    {
        //Verify using Talao token if sender is authorized to create a Vault
        bool agreement = false;
        uint unused = 0;
        (agreement, unused) = myToken.AccessAllowance(msg.sender,msg.sender);

        require (agreement == true);
        require(FreelanceVault[msg.sender] == address(0));

        Vault newVault = new Vault(myToken);
        FreelanceVault[msg.sender] = address(newVault);
        SafeMath.add(nbVault,1);
        newVault.transferOwnership(msg.sender);

        emit VaultCreation(msg.sender, newVault, VaultState.Created);

        return address(newVault);
    }

    /**
     * Prevents accidental sending of ether to the factory
     */
    function ()
        public
    {
        revert();
    }
}

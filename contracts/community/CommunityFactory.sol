pragma solidity ^0.4.21;

import '../ownership/Ownable.sol';
import '../TalaoToken.sol';
import '../freelancer/Freelancer.sol';
import './Community.sol';

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

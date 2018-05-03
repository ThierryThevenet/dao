import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { NotificationManager } from 'react-notifications';
import FontAwesomeIcon from '@fortawesome/react-fontawesome';
import faLock from '@fortawesome/fontawesome-free-solid/faLock';
import faLockOpen from '@fortawesome/fontawesome-free-solid/faLockOpen';
import Button from '../ui/button/Button';
import faSignInAlt from '@fortawesome/fontawesome-free-solid/faSignInAlt';
import List from "../ui/list/List";
import './Community.css';

export default class Community extends Component {
  constructor (props) {
    super (props);

    const communityContract = new window.web3.eth.Contract (
      JSON.parse(process.env.REACT_APP_COMMUNITY_ABI),
      this.props.match.params.communityAddress
    );

    const freelancerContract = new window.web3.eth.Contract (
      JSON.parse(process.env.REACT_APP_FREELANCER_ABI),
      process.env.REACT_APP_FREELANCER_ADDRESS
    );

    this.state = {
      communityContract: communityContract,
      communityAddress: this.props.match.params.communityAddress,
      communityName: null,
      communityIsActive: null,
      communityIsPrivate: null,
      communitySponsor: null,
      communityIsSponsored: false,
      communityBalanceToVote: null,
      communityMinimumTokensToVote: null,
      communityMinimumReputationToVote: null,
      communityJobCommission: null,
      communityJoinFee: null,
      communityMembers: [],
      freelancerContract: freelancerContract,
      freelancerIsActive: null,
      freelancerIsCommunityMember: null,
    }

    this.handleJoinDaoClick = this.handleJoinDaoClick.bind(this);
    this.handleJoinCommunityClick = this.handleJoinCommunityClick.bind(this);
  }
  componentDidMount() {
    // Active community?
    this.state.communityContract.methods.communityIsActive().call().then(communityIsActive => {
      this.setState ({
        communityIsActive: communityIsActive
      });
      // Community name.
      this.state.communityContract.methods.communityName().call().then(communityName => {
        this.setState ({
          communityName: communityName
        });
      });
      // Private community?
      this.state.communityContract.methods.communityIsPrivate().call().then(communityIsPrivate => {
        this.setState ({
          communityIsPrivate: communityIsPrivate
        });
      });
      // Sponsor address if private community.
      this.state.communityContract.methods.communitySponsor().call().then(communitySponsor => {
        if (communitySponsor !== '0x0000000000000000000000000000000000000000') {
          this.setState ({
            communitySponsor: communitySponsor,
            communityIsSponsored: true
          });
        }
      });
      // Token percentage balance to vote in community (10 = 10% token, 90% reputation). From 1 to 100.
      this.state.communityContract.methods.communityBalanceToVote().call().then(communityBalanceToVote => {
        this.setState ({
          communityBalanceToVote: communityBalanceToVote
        });
      });
      // Minimum tokens to vote in community. From 1 to 100.
      this.state.communityContract.methods.communityMinimumTokensToVote().call().then(communityMinimumTokensToVote => {
        this.setState ({
          communityMinimumTokensToVote: communityMinimumTokensToVote
        });
      });
      // Minimum reputation to vote in community. From 1 to 100.
      this.state.communityContract.methods.communityMinimumReputationToVote().call().then(communityMinimumReputationToVote => {
        this.setState ({
          communityMinimumReputationToVote: communityMinimumReputationToVote
        });
      });
      // (Community commission on job) / 100. 100 means 1%. From 0 to 10000.
      this.state.communityContract.methods.communityJobCommission().call().then(communityJobCommission => {
        this.setState ({
          communityJobCommission: communityJobCommission
        });
      });
      // Fee to join community.
      this.state.communityContract.methods.communityJoinFee().call().then(communityJoinFee => {
        this.setState ({
          communityJoinFee: communityJoinFee
        });
      });
      // Is the freelancer registred and active in the DAO?
      this.state.freelancerContract.methods.isFreelancerActive(this.context.web3.selectedAccount).call().then(freelancerIsActive => {
        this.setState({
          freelancerIsActive: freelancerIsActive
        });
        // Is the freelance registred in the community?
        this.state.communityContract.methods.communityMembers(this.context.web3.selectedAccount).call().then(freelancerIsCommunityMember => {
          this.setState({
            freelancerIsCommunityMember: freelancerIsCommunityMember
          });
          // If the freelancer is a member, retrieve his community information.
          if (freelancerIsCommunityMember) {
            // TODO
          }
        });
      });
      // Freelancers that belong to this community.
      this.state.communityContract.getPastEvents(
        'CommunitySubscription',
        {
          fromBlock: 0,
          toBlock: 'latest'
        }
      ).then( events => {
        let communityMembers = [];
        events.forEach ( (event) => {
          let freelancerAddress = event['returnValues']['_freelancerAddress'];
          communityMembers.push({
            link: freelancerAddress,
            anchor: freelancerAddress
          });
        });
        this.setState({
          communityMembers: communityMembers
        });
      });
    });
  }
  handleJoinDaoClick() {
    this.state.freelancerContract.methods
      .joinDao()
      .send({from: this.context.web3.selectedAccount})
      .on('transactionHash', (hash) => {
        let message = 'Joining the Talao DAO (transaction hash: ' + hash + ')';
        NotificationManager.create({
          id: 300,
          type: 'info',
          message: message,
          title: 'Transaction submitted',
          timeOut: 0,
        });
      })
      .on('receipt', (receipt) => {
        let message = 'Joining the Talao DAO';
        NotificationManager.remove({id: 300});
        NotificationManager.create({
          id: 301,
          type: 'info',
          message: message,
          title: 'Transaction received',
          timeOut: 0,
        });
      })
      // TODO: Investigate: confirmationNumber goes up to 24 but it should not since no other block is mined locally.
      // It should go up to 12, one for each new mined block: https://web3js.readthedocs.io/en/1.0/web3-eth.html#sendtransaction
      .on('confirmation', (confirmationNumber, receipt) => {
        if (confirmationNumber === 1) {
          let message = 'You joined the Talao DAO! Welcome :)';
          NotificationManager.remove({id: 301});
          NotificationManager.success(message, 'Transaction completed');
          this.setState({
            freelancerIsActive: true
          });
        }
      })
      .on('error', console.error);
  }
  handleJoinCommunityClick() {
    this.state.communityContract.methods
      .joinCommunity()
      .send({from: this.context.web3.selectedAccount})
      .on('transactionHash', (hash) => {
        let message = 'Joining this community (transaction hash: ' + hash + ')';
        NotificationManager.create({
          id: 310,
          type: 'info',
          message: message,
          title: 'Transaction submitted',
          timeOut: 0,
        });
      })
      .on('receipt', (receipt) => {
        let message = 'Joining this community';
        NotificationManager.remove({id: 310});
        NotificationManager.create({
          id: 311,
          type: 'info',
          message: message,
          title: 'Transaction received',
          timeOut: 0,
        });
      })
      // TODO: Investigate: confirmationNumber goes up to 24 but it should not since no other block is mined locally.
      // It should go up to 12, one for each new mined block: https://web3js.readthedocs.io/en/1.0/web3-eth.html#sendtransaction
      .on('confirmation', (confirmationNumber, receipt) => {
        if (confirmationNumber === 1) {
          let message = 'You joined this community!';
          NotificationManager.remove({id: 311});
          NotificationManager.success(message, 'Transaction completed');
          this.setState({
            freelancerIsCommunityMember: true
          });
        }
      })
      .on('error', console.error);
  }
  render() {
    return (
      <div className = "Community">
        <div
          className = "Community-active"
          style = { this.state.communityIsActive ? {} : { display: 'none' }}>
          <h1>
            { this.state.communityName + ' ' }
            { this.state.communityIsPrivate && <FontAwesomeIcon icon = { faLock } /> }
            { !this.state.communityIsPrivate && <FontAwesomeIcon icon = { faLockOpen } /> }
          </h1>
          <div className = "Community-info blue box">
            {
              this.state.communityIsSponsored &&
              <div className = "Community-info-sponsor">
                <h2>Sponsored by</h2>
                <a
                  href={ 'https://ropsten.etherscan.io/address/' + this.state.communitySponsor }
                  target="_blank" rel="noopener noreferrer">
                    { this.state.communitySponsor }
                </a>
              </div>
            }
            <h2>Address</h2>
            <a
              href={ 'https://ropsten.etherscan.io/address/' + this.state.communityAddress }
              target="_blank" rel="noopener noreferrer">
                { this.state.communityAddress }
            </a>
            <h2>Parameters</h2>
            <ul>
              <li>
                Balance to vote: { this.state.communityBalanceToVote }% tokens / { 100 - this.state.communityBalanceToVote }% reputation
              </li>
              <li>
                Minimum tokens to vote: { this.state.communityMinimumTokensToVote } tokens
              </li>
              <li>
                Minimum reputation to vote: { this.state.communityMinimumReputationToVote }
              </li>
              <li>
                Community commission on jobs: { this.state.communityJobCommission / 100 }%
              </li>
              <li>
                Fee to join: { this.state.communityJoinFee } tokens
              </li>
            </ul>
          </div>
          <div className = "Community-Freelancer">
            <h2>Me and this community</h2>
            <div
              className = "Community-Freelancer-active"
              style = { this.state.freelancerIsActive ? {} : { display: 'none' }}>
              <div
                className = "Community-Freelancer-active-member green box"
                style = { this.state.freelancerIsCommunityMember ? {} : { display: 'none' }}>
                  <p>You belong to this community. Keep up the good work!</p>
              </div>
              <div
                className = "Community-Freelancer-active-notmember yellow box"
                style = { this.state.freelancerIsCommunityMember ? { display: 'none' } : {}}>
                <p>You do not belong yet to this Talao DAO community.</p>
                <Button
                  value = "Join this community"
                  icon = { faSignInAlt }
                  onClick = { this.handleJoinCommunityClick } />
              </div>
            </div>
            <div
              className = "Community-Freelancer-inactive yellow box"
              style = { this.state.freelancerIsActive ? { display: 'none' } : {}}>
              <p>Your Ethereum address is not registred yet as a freelancer in Talao DAO.</p>
              <Button
                value = "Join the Talao DAO"
                icon = { faSignInAlt }
                onClick = { this.handleJoinDaoClick } />
            </div>
          </div>
          <div className = "Community-Freelancer-members">
            <h2>Freelancers in this community</h2>
            <div className = "yellow box">
              <List
                list = { this.state.communityMembers }
                resultsText = 'Those freelancers belong to this community:'
                noResultsText = 'No freelancer belongs to this community yet.'
                route = 'freelancer'
              />
            </div>
          </div>
        </div>
        <div
          className = "Community-inactive"
          style = { this.state.communityIsActive ? { display: 'none' } : {}}>
            <p>This is not an active community.</p>
          </div>
      </div>
    );
  }
}

Community.contextTypes = {
  web3: PropTypes.object
}

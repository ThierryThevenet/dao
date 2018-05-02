import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { NotificationManager } from 'react-notifications';
import { CopyToClipboard } from 'react-copy-to-clipboard';
import Button from '../ui/button/Button';
import faCopy from '@fortawesome/fontawesome-free-solid/faCopy';
import List from '../ui/list/List';
import './FreelancerProfile.css';

export default class FreelancerProfile extends Component {
  constructor (props) {
    super (props);

    const freelancerContract = new window.web3.eth.Contract (
      JSON.parse(process.env.REACT_APP_FREELANCER_ABI),
      process.env.REACT_APP_FREELANCER_ADDRESS
    );

    const communityFactoryContract = new window.web3.eth.Contract (
      JSON.parse(process.env.REACT_APP_COMMUNITY_FACTORY_ABI),
      process.env.REACT_APP_COMMUNITY_FACTORY_ADDRESS
    );

    this.state = {
      freelancerContract: freelancerContract,
      isFreelancerActive: null,
      isFreelancerBlocked: null,
      communityFactoryContract: communityFactoryContract,
      freelancerCommunities: []
    }
  }
  componentDidMount() {
    // Is the freelancer registred and active in the DAO?
    this.state.freelancerContract.methods.isFreelancerActive(this.props.match.params.freelancerAddress)
    .call()
    .then(isFreelancerActive => {
      this.setState({
        isFreelancerActive: isFreelancerActive
      });
      // Get all the communities.
      let freelancerCommunities = [];
      this.state.communityFactoryContract.getPastEvents('CommunityListing', {}, {fromBlock: 0, toBlock: 'latest'})
      .then( events => {
        events.forEach( (event) => {
          // Does the freelancer belong to this community?
          let communityAddress = event['returnValues']['community'];
          let communityContract = new window.web3.eth.Contract (
            JSON.parse(process.env.REACT_APP_COMMUNITY_ABI),
            communityAddress
          );
          communityContract.getPastEvents(
            'CommunitySubscription',
            {
              filter: {
                _freelancerAddress: this.props.match.params.freelancerAddress
              },
              fromBlock: 0,
              toBlock: 'latest'
            }
          ).then( events => {
            events.forEach ( (event) => {
              // Active community?
              communityContract.methods.communityIsActive().call().then(communityIsActive => {
                if (communityIsActive) {
                  // Community name.
                  communityContract.methods.communityName().call().then(communityName => {
                    freelancerCommunities.push({
                      link: communityAddress,
                      anchor: communityName
                    });
                    this.setState({
                      freelancerCommunities: freelancerCommunities
                    });
                  });
                }
              });
            });
          });
        });
      });
    });
  }
  render() {
    return (
      <div className = "FreelancerProfile">
        <h1>Freelancer { this.props.match.params.freelancerAddress }</h1>
        <div
          className = "FreelancerProfile-active"
          style = { this.state.isFreelancerActive ? {} : { display: 'none' }}>
          <div className = "FreelancerProfile-ethereum-address blue-dark box">
            <h2>Ethereum address</h2>
            <p>
              { this.props.match.params.freelancerAddress }
              <CopyToClipboard
                text = { this.props.match.params.freelancerAddress }
                onCopy = { () => NotificationManager.success('Copied to clipboard') }>
                <Button
                  value = "copy"
                  icon = { faCopy } />
              </CopyToClipboard>
            </p>
          </div>
          <div className = "FreelancerProfile-communities yellow box">
            <h2>Communities</h2>
            <List
              list = { this.state.freelancerCommunities }
              resultsText = 'This freelancer belongs to these communities:'
              noResultsText = 'This freelancer does not belong to any community yet.'
              route = 'community'
            />
          </div>
        </div>
        <div
          className = "FreelancerProfile-inactive blue-dark box"
          style = { this.state.isFreelancerActive ? { display: 'none' } : {}}>
          <p>Sorry, there is no Freelancer with such Ethereum address in the Talao DAO...</p>
        </div>
      </div>
    );
  }
}

FreelancerProfile.contextTypes = {
  web3: PropTypes.object
}

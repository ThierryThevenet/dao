import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { NotificationManager } from 'react-notifications';
import { CopyToClipboard } from 'react-copy-to-clipboard';
import Button from '../ui/button/Button';
import faCopy from '@fortawesome/fontawesome-free-solid/faCopy';
import List from '../ui/list/List';
import VaultGetAccess from '../vault/VaultGetAccess';
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

    const vaultFactoryContract = new window.web3.eth.Contract(
        JSON.parse(process.env.REACT_APP_VAULTFACTORY_ABI),
        process.env.REACT_APP_VAULTFACTORY_ADDRESS
    );

    const tokenContract = new window.web3.eth.Contract(
        JSON.parse(process.env.REACT_APP_TOKEN_ABI),
        process.env.REACT_APP_TOKEN_ADDRESS
    );

    this.state = {
      freelancerContract: freelancerContract,
      isFreelancerActive: null,
      isFreelancerBlocked: null,
      communityFactoryContract: communityFactoryContract,
      freelancerCommunities: [],
      vaultFactoryContract: vaultFactoryContract,
      freelancerHasVault: null,
      freelancerGetVaultAccess: null,
      freelancerDisplayVault: null,
      freelancerVaultPrice: null,
      tokenContract: tokenContract,
      tokenSymbol: null
    }

    this.handleVaultGetAccessClick = this.handleVaultGetAccessClick.bind(this);
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
      // Does the freelancer have a Vault?
      this.state.vaultFactoryContract.methods.FreelanceVault(this.props.match.params.freelancerAddress)
      .call()
      .then(vaultAddress => {
        // Yes, the freelancer has a Vault.
        if (vaultAddress !== '0x0000000000000000000000000000000000000000') {
          this.setState({
            freelancerHasVault: true
          });
          // Does the client has access to the Vault?
          this.state.tokenContract.methods.accessAllowance(
            this.context.web3.selectedAccount,
            this.props.match.params.freelancerAddress
          )
          .call()
          .then( clientAccess => {
            // Yes => display Vault.
            if (clientAccess.clientAgreement) {
              console.log('display vault');
            }
            // No => is the Vault access open?
            else {
              // Get Vault access price.
              this.state.tokenContract.methods.data(this.props.match.params.freelancerAddress)
              .call()
              .then( freelanceData => {
                let freelancerVaultPriceWei = freelanceData.accessPrice;
                let freelancerVaultPrice = window.web3.utils.fromWei(freelancerVaultPriceWei);
                // Get token symbol.
                this.state.tokenContract.methods.symbol()
                .call()
                .then( symbol => {
                  this.setState({
                    freelancerGetVaultAccess: true,
                    freelancerVaultPrice: freelancerVaultPrice,
                    tokenSymbol: symbol
                  });
                });
              });
            }
          });
        }
      });
    });
  }
  handleVaultGetAccessClick() {
    console.log(this.props.match.params.freelancerAddress);
    console.log(this.context.web3.selectedAccount);
    this.state.tokenContract.methods
      .getVaultAccess(this.props.match.params.freelancerAddress)
      .send({from: this.context.web3.selectedAccount})
      .on('transactionHash', (hash) => {
        this.setState({
          freelancerGetVaultAccess: false
        });
        let message = 'Getting access to Vault of freelancer ' + this.props.match.params.freelancerAddress + ' for ' + this.state.vaultPrice + ' ' + this.state.tokenSymbol + ' tokens (transaction hash: ' + hash + ')';
        NotificationManager.create({
          id: 450,
          type: 'info',
          message: message,
          title: 'Transaction submitted',
          timeOut: 0,
        });
      })
      .on('receipt', (receipt) => {
        let message = 'Getting access to Vault of freelancer ' + this.props.match.params.freelancerAddress + ' for ' + this.state.vaultPrice + ' ' + this.state.tokenSymbol + ' tokens';
        NotificationManager.remove({id: 450});
        NotificationManager.create({
          id: 451,
          type: 'info',
          message: message,
          title: 'Transaction received',
          timeOut: 0,
        });
      })
      .on('confirmation', (confirmationNumber, receipt) => {
        if (confirmationNumber === 1) {
          let message = 'You bought an access to the Vault of the freelancer ' + this.props.match.params.freelancerAddress + ' for ' + this.state.vaultPrice + ' ' + this.state.tokenSymbol + ' tokens';
          NotificationManager.remove({id: 451});
          NotificationManager.success(message, 'Transaction completed');
          this.setState({
            freelancerDisplayVault: true
          })
        }
      })
      .on('error', console.error);
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
          <div className = "FreelancerProfile-communities green box">
            <h2>Communities</h2>
            <List
              list = { this.state.freelancerCommunities }
              resultsText = 'This freelancer belongs to these communities:'
              noResultsText = 'This freelancer does not belong to any community yet.'
              route = 'community'
            />
          </div>
          <div className = "FreelancerProfile-vault yellow box">
            <h2>Vault</h2>
            <div
              className = "FreelancerProfile-vault-novault"
              style = { this.state.freelancerHasVault ? { display: 'none' } : {}}>
              <p>This freelancer has no Vault yet.</p>
            </div>
            <div
              className = "FreelancerProfile-vault-vault"
              style = { this.state.freelancerHasVault ? {} : { display: 'none' }}>
              <div
                className = "FreelancerProfile-vault-vault-get"
                style = { this.state.freelancerGetVaultAccess ? {} : { display: 'none' }}>
                <VaultGetAccess
                  address = { this.props.match.params.freelancerAddress }
                  price = { this.state.freelancerVaultPrice }
                  tokenSymbol = { this.state.tokenSymbol }
                  onClick = { this.handleVaultGetAccessClick } />
              </div>
              <div
                className = "FreelancerProfile-vault-vault-display"
                style = { this.state.freelancerDisplayVault ? {} : { display: 'none' }}>
                <p>TODO: display vault</p>
              </div>
            </div>
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

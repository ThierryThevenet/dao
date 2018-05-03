import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { NotificationManager } from 'react-notifications';
import { CopyToClipboard } from 'react-copy-to-clipboard';
import Button from '../ui/button/Button';
import faCopy from '@fortawesome/fontawesome-free-solid/faCopy';
import List from '../ui/list/List';
import VaultGetAccess from '../vault/VaultGetAccess';
import VaultView from '../vault/VaultView';
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
      freelancerVaultView: null,
      freelancerVaultPrice: null,
      freelancerVaultDocuments: [],
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
      .then(freelancerVaultAddress => {
        // Yes, the freelancer has a Vault.
        if (freelancerVaultAddress !== process.env.REACT_APP_NO_ADDRESS) {
          this.setState({
            freelancerHasVault: true
          });
          // Does the client have access to the Vault?
          this.state.tokenContract.methods.accessAllowance(
            this.context.web3.selectedAccount,
            this.props.match.params.freelancerAddress
          )
          .call()
          .then( clientAccess => {
            // Yes => display Vault.
            if (clientAccess.clientAgreement) {
              this.setState({
                freelancerVaultView: true
              });
              // Load Vault contract.
              const freelancerVaultContract = new window.web3.eth.Contract(
                JSON.parse(process.env.REACT_APP_VAULT_ABI),
                freelancerVaultAddress
              );
              // Get documents.
              let freelancerVaultDocuments = [];
              freelancerVaultContract.getPastEvents('VaultDocAdded', {}, { fromBlock: 0, toBlock: 'latest' })
              .then(events => {
                events.forEach(event => {
                  // Document.
                  let doc = {
                    ipfsHash: event['returnValues']['documentId'].toString(),
                    description: window.web3.utils.hexToAscii(event['returnValues']['description']).replace(/\u0000/g, '')
                  }
                  // Is the document still OK or was it "suppressed"?
                  freelancerVaultContract.methods.getDocumentIsAlive(doc.ipfsHash)
                  .call({from: this.context.web3.selectedAccount})
                  .then(documentIsAlive => {
                    if (documentIsAlive) {
                      freelancerVaultDocuments.push(doc);
                      this.setState({
                        freelancerVaultDocuments: freelancerVaultDocuments
                      });
                    }
                  });
                });
              });
            }
            // No => propose to pay access to vault.
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
            freelancerVaultView: true
          })
        }
      })
      .on('error', console.error);
  }
  render() {
    return (
      <div className = "FreelancerProfile">
        <h1>Freelancer { this.props.match.params.freelancerAddress }</h1>
        <p>
          <CopyToClipboard
            text = { this.props.match.params.freelancerAddress }
            onCopy = { () => NotificationManager.success('Copied to clipboard') }>
            <Button
              value = "copy address"
              icon = { faCopy } />
          </CopyToClipboard>
        </p>
        <div
          className = "FreelancerProfile-active"
          style = { this.state.isFreelancerActive ? {} : { display: 'none' }}>
          <h2>This Freelancer Vault</h2>
          <div className = "FreelancerProfile-vault green box">
            <div
              className = "FreelancerProfile-vault-novault"
              style = { this.state.freelancerHasVault ? { display: 'none' } : {}}>
              <p>This Freelancer has no Vault yet.</p>
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
                style = { this.state.freelancerVaultView ? {} : { display: 'none' }}>
                <VaultView documents = { this.state.freelancerVaultDocuments } />
              </div>
            </div>
          </div>
          <h2>This Freelancer Communities</h2>
          <div className = "FreelancerProfile-communities yellow box">
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

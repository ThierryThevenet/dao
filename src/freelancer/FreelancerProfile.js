import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { NotificationManager } from 'react-notifications';
import { CopyToClipboard } from 'react-copy-to-clipboard';
import Button from '../ui/button/Button';
import faCopy from '@fortawesome/fontawesome-free-solid/faCopy';
import './FreelancerProfile.css';

class FreelancerProfile extends Component {
  constructor (props) {
    super (props);

    const freelancerContract = new window.web3.eth.Contract (
      JSON.parse(process.env.REACT_APP_FREELANCER_ABI),
      process.env.REACT_APP_FREELANCER_ADDRESS
    );

    this.state = {
      freelancerContract: freelancerContract,
      isFreelancerActive: null,
      isFreelancerBlocked: null
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
    });
  }
  render() {
    return (
      <div className = "FreelancerProfile">
        <h1>Profile for this Freelancer</h1>
        <div
          className = "FreelancerProfile-active blue-dark box"
          style = { this.state.isFreelancerActive ? {} : { display: 'none' }}>
          <div className="FreelancerProfile-ethereum-address">
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

export default FreelancerProfile;

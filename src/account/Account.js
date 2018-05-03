import React, { Component } from 'react';
import Freelancer from '../freelancer/Freelancer';
import Vault from '../vault/Vault';
import Token from '../token/Token';
import Ethereum from '../ethereum/Ethereum';
import './Account.css';

class Account extends Component {
  render() {
    return (
      <div className="Account">
        <h1>My account</h1>
        <Freelancer />
        <Vault />
        <Token />
        <Ethereum />
      </div>
    );
  }
}

export default Account;

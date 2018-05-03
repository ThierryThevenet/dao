import React, { Component } from 'react';
import Button from '../ui/button/Button';
import faLock from '@fortawesome/fontawesome-free-solid/faLock';

export default class VaultGetAccess extends Component {
  render() {
    return (
      <div className = "VaultGetAccess">
        <p>This freelancer has set up the price to access his Vault to <strong>{ this.props.price } { this.props.tokenSymbol } tokens</strong>. This is a <strong>one-time payment</strong>. Should the freelancer close new accesses to his Vault, you will always keep your paid access.</p>
        <p>If you click on the button below and sign the transaction, <strong>you will transfer { this.props.price } { this.props.tokenSymbol } tokens</strong> to Talao. Talao will then transfer them back to this freelancer in totality if the freelancer has no agent. If the freelancer has an agent, Talao will transfer their shares to each other, according to the freelancer's Vault settings.</p>
        <Button
          value = { 'Get Vault access for ' + this.props.price + ' ' + this.props.tokenSymbol + ' tokens' }
          icon = { faLock }
          onClick = { this.props.onClick } />
      </div>
    );
  }
}

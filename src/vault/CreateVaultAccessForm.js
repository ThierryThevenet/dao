import React, { Component } from 'react';
import '../ui/form/Form.css';
import './CreateVaultAccessForm.css';

export default class CreateVaultAccessForm extends Component {
  render() {
    return (
      <div className = "CreateVaultAccess-token-form">
        <form
          className = "pure-form pure-form-aligned"
          onSubmit = { this.props.onSubmit }>
          <fieldset>
            <div className = "pure-control-group">
              <input
                name = "vaultPrice"
                type = "text"
                className = "pure-input-1"
                placeholder = { 'Price (in ' + this.props.tokenSymbol + ' tokens) clients will pay you to access your Vault' }
                value = { this.props.vaultPrice }
                onChange = { this.props.onChange } />
            </div>
            <div className = "pure-control-group">
              <input
                className = "pure-input-1 pure-button btn"
                type = "submit"
                value = "Set price" />
            </div>
          </fieldset>
        </form>
      </div>
    );
  }
}

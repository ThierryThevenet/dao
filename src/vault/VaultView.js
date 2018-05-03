import React, { Component } from 'react';
import bs58 from 'bs58';
import './VaultView.css';

export default class VaultView extends Component {
  render() {
    if (this.props.documents.length > 0) {
      return this.renderDocuments();
    }
    else {
      return this.renderNoDocuments();
    }
  }
  renderDocuments() {
    return (
      <div className = "VaultDocuments">
        <ul>
          {
            this.props.documents.map(
              (item, index) => (
                this.renderItem(item, index)
              )
            )
          }
        </ul>
      </div>
    );
  }
  renderItem(item, index) {
    return (
      <li key = { index }>
        <a
          href = { 'https://ipfs.io/ipfs/' + this.getIpfsHashFromBytes32(item.ipfsHash) }
          target="_blank"
          rel="noopener noreferrer"
        >
          { item.description }
        </a>
      </li>
    );
  }
  getIpfsHashFromBytes32(bytes32Hex) {
    let hashHex = "1220" + bytes32Hex.slice(2);
    let hashBytes = Buffer.from(hashHex, 'hex');
    let hashStr = bs58.encode(hashBytes);
    return hashStr;
  }
  renderNoDocuments() {
    return (
      <div className = "VaultNoDocuments">
        <p>This freelancer has no more documents in his Vault.</p>
      </div>
    );
  }
}

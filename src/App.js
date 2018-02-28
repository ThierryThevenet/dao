import React, { Component } from 'react';
import logo from './assets/images/Talao-logo.png';
import './App.css';
import Web3 from './web3/Web3';
//import AppConnected from './AppConnected';

class App extends Component {
  render() {
    return (
      <div className="App">
        <header className="App-header">
          <a href="/">
            <img src={logo} className="App-header-logo" alt="logo" />
          </a>
          <h1 className="App-header-title">Talao</h1>
          <p>The first Ethereum-based Talents Autonomous Organization.</p>
        </header>
        <section className="App-content">
          <Web3 />
        </section>
        <footer className="App-footer">
          <p><a href="https://talao.io" target="_blank" rel="noopener noreferrer">Talao</a> DAO prototype v0.2.1</p>
        </footer>
      </div>
    );
  }
}

export default App;

import React, { Component } from 'react';
import { BrowserRouter as Router, Route, Link } from 'react-router-dom';
import './AppConnected.css';
import FontAwesomeIcon from '@fortawesome/react-fontawesome';
import Home from './home/Home';
import faHome from '@fortawesome/fontawesome-free-solid/faHome';
import Communities from './community/Communities';
import Community from './community/Community';
import Objection from './objection/Objection';
import Account from './account/Account';
import FreelancerProfile from './freelancer/FreelancerProfile';
import faUsers from '@fortawesome/fontawesome-free-solid/faUsers';
import faCog from '@fortawesome/fontawesome-free-solid/faCog';
import faUser from '@fortawesome/fontawesome-free-solid/faUser';

class AppConnected extends Component {
  constructor (props) {
    super (props);

    this.state = {
      network: null
    }
  }
  componentWillMount() {
    window.web3.eth.net.getNetworkType().then(network => {
      this.setState({
        network: network
      })
    });
  }
  render() {
    if (this.state.network !== process.env.REACT_APP_NETWORK) {
      return (
        <div className="Web3Wrapper blue">
          <p>Please switch to { process.env.REACT_APP_NETWORK } network.</p>
        </div>
      )
    }
    else {
      return (
        <div className="AppConnected">
          <Router>
            <div>
              <nav className="AppConnected-menu blue-light">
                <ul>
                  <li>
                    <Link to="/" className="hvr-shutter-in-horizontal"><FontAwesomeIcon icon={ faHome } /></Link>
                  </li>
                  <li>
                    <Link to="/communities"><FontAwesomeIcon icon={ faUsers } /> Communities</Link>
                  </li>
                  <li>
                    <Link to="/objections"><FontAwesomeIcon icon={ faCog } /> Objections</Link>
                  </li>
                  <li>
                    <Link to="/account"><FontAwesomeIcon icon={ faUser } /> My account</Link>
                  </li>
                </ul>
              </nav>
              <Route exact path = "/" component = { Home } />
              <Route path = "/communities" component = { Communities } />
              <Route path = "/community/:communityAddress" component = { Community } />
              <Route path = "/objections" component = { Objection } />
              <Route path = "/account" component = { Account } />
              <Route path = "/freelancer/:freelancerAddress" component = { FreelancerProfile } />
            </div>
          </Router>
        </div>
      );
    }
  }
}

export default AppConnected;

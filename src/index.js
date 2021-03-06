import React from 'react';
import ReactDOM from 'react-dom';
import 'purecss';
import './index.css';
import App from './App';
import registerServiceWorker from './registerServiceWorker';
if (process.env.REACT_APP_FONT === '1') {
  require('./assets/fonts/akkmono.eot');
  require('./assets/fonts/akkmono.woff');
  require('./assets/fonts/akkmono.ttf');
  require('./fonts.css');
}

ReactDOM.render(
  <App />,
  document.getElementById('root')
);
registerServiceWorker();

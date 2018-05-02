import React, { Component } from 'react';

export default class List extends Component {
  renderItem(item, index) {
    return (
      <li key = { index }>
        <a href = { '/' + this.props.route + '/' + item.link }>
          { item.anchor }
        </a>
      </li>
    );
  }
  renderList(list) {
    if (list.length > 0) {
      return (
        <ul>
          {
            list.map(
              (item, index) => (
                this.renderItem(item, index)
              )
            )
          }
        </ul>
      );
    }
  }
  render() {
    if (this.props.list.length > 0) {
      return (
        <div className = "List">
          <div className="List-results">
            <p>{ this.props.resultsText }</p>
            { this.renderList(this.props.list) }
          </div>
        </div>
      );
    }
    else {
      return (
        <div className = "List">
          <div className="List-noresults">
            <p>{ this.props.noResultsText }</p>
          </div>
        </div>
      );
    }
  }
}

import React from 'react'

export default class ShareTrades extends React.Component {
   constructor(...args) {
      super(...args);
      this.state = {
         text: '',
      };
   }

   handleExport() {
      this.setState({
         text: JSON.stringify(this.props.trades),
      });
   }

   handleImport() {
      this.props.onChangeTrades(JSON.parse(this.state.text));
   }

   handleChangeText(e) {
      this.setState({
         text: e.target.value,
      });
   }

   render() {
      return (
         <div className="share-trades">
            <div>
               <textarea className="share-text" value={this.state.text} onChange={this.handleChangeText.bind(this)} />
            </div>
            <button onClick={this.handleExport.bind(this)}>エクスポート</button>
            <button onClick={this.handleImport.bind(this)}>インポート</button>
         </div>
      );
   }
}
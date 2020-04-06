import React from 'react'
import {idmax} from './NewTrade';

export function sanitize(trades) {
   const ids = [];
   let maxId = 0;
   const ret = [];
   const extra = [];
   trades.forEach(trade => {
      if (ids[trade.id]) {
         extra.push(trade);
      } else {
         ret.push(trade);
         ids[trade.id] = true;
         maxId = Math.max(maxId, trade.id);
      }
   });
   extra.forEach(trade => {
      ret.push({...trade, id: ++maxId});
   });
   idmax.value = maxId;
   return ret;
}

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
      this.props.onChangeTrades(sanitize(JSON.parse(this.state.text)));
   }

   handleReset() {
      this.props.onChangeTrades([]);
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
            <button onClick={this.handleReset.bind(this)}>リセット</button>
         </div>
      );
   }
}
import React from 'react'
import {idmax} from './NewTrade';
import {db} from './firebase';
import {formatDate} from './date';

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

export default function ShareTrades(props) {
   if (db) {
      return <ShareTradesWithFirestore trades={props.trades} onChangeTrades={props.onChangeTrades} />
   } else {
      return <ShareTradesWithoutFirestore trades={props.trades} onChangeTrades={props.onChangeTrades} />
   }
}

class ShareTradesWithoutFirestore extends React.Component {
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

class ShareTradesWithFirestore extends React.Component {
   constructor(...args) {
      super(...args);
      this.state = {
         revision: '',
         revisions: [],
      };
   }

   componentDidMount() {
      this.loadRevisions();
   }

   loadRevisions() {
      db.collection("trades").get().then((querySnapshot) => {
         const revisions = [];
         querySnapshot.forEach((doc) => {
            revisions.push(doc.id);
         });
         revisions.sort((a, b) => Number(b) - Number(a));
         this.setState({revisions});
      });
   }

   handleExport() {
      const docId = formatDate(new Date());
      db.collection('trades').doc(docId)
         .set({
            data: this.props.trades,
         })
         .then(() => this.loadRevisions());
   }

   handleImport() {
      const revision = this.state.revision !== '' ? this.state.revision : this.state.revisions[0];
      db.collection("trades").doc(revision).get().then((doc) => {
         if (!doc.exists) {
            this.setState({
               error: 'データの読み込みに失敗しました。',
            });
         } else {
            this.setState({
               error: null,
            });
            this.props.onChangeTrades(sanitize(doc.data().data));
         }
      });
   }

   handleReset() {
      this.props.onChangeTrades([]);
   }

   handleChangeRevision(e) {
      this.setState({revision: e.target.value});
   }

   render() {
      return (
         <div className="share-trades">
            <div>
               <button onClick={this.handleExport.bind(this)}>サーバーにエクスポート</button>
            </div>
            <div>
               <select value={this.state.revision} onChange={this.handleChangeRevision.bind(this)} >
                  <option value="">最新</option>
                  {this.state.revisions.map(rev => <option value={rev} key={rev}>{rev}</option>)}
               </select>
               <button onClick={this.handleImport.bind(this)}>サーバーからインポート</button>
               {this.state.error && <div style={{color: 'red'}}>{this.state.error}</div>}
            </div>
            <button onClick={this.handleReset.bind(this)}>リセット</button>
         </div>
      );
   }
}
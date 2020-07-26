import React from 'react'
import {idmax} from './NewTrade';
import {db} from '../firebase';
import {formatDate} from '../date';
import TextInput from '../form/TextInput';

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
         revisionName: '',
      };
   }

   componentDidMount() {
      this.loadRevisions();
   }

   loadRevisions() {
      db.collection("trades").get().then((querySnapshot) => {
         const docs = [];
         querySnapshot.forEach((doc) => {
            docs.push(doc);
         });
         docs.sort((a, b) => Number(b.id) - Number(a.id));
         const revisions = docs.slice(0, 5)
            .map(doc => ({
               id: doc.id,
               name: doc.data().name,
            }));
         this.setState({revisions});
      });
   }

   handleExport() {
      const docId = formatDate(new Date());
      db.collection('trades').doc(docId)
         .set({
            data: this.props.trades,
            name: this.state.revisionName,
         })
         .then(() => this.loadRevisions());
      this.setState({
         revisionName: '',
      });
   }

   handleImport() {
      const revision = this.state.revision !== '' ? this.state.revision : this.state.revisions[0].id;
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

   handleChangeRevisionName(revisionName) {
      this.setState({revisionName});
   }

   render() {
      return (
         <div className="share-trades">
            <div>
               <TextInput value={this.state.revisionName} onChange={this.handleChangeRevisionName.bind(this)} />
               <button onClick={this.handleExport.bind(this)}>サーバーにエクスポート</button>
            </div>
            <div>
               <select value={this.state.revision} onChange={this.handleChangeRevision.bind(this)} >
                  {this.state.revisions.map((rev, i) => <option value={rev.id} key={rev.id}>{i == 0 ? '[最新] ' : ''}{rev.name} ({rev.id})</option>)}
               </select>
               <button onClick={this.handleImport.bind(this)}>サーバーからインポート</button>
               {this.state.error && <div style={{color: 'red'}}>{this.state.error}</div>}
            </div>
            <button onClick={this.handleReset.bind(this)}>リセット</button>
         </div>
      );
   }
}
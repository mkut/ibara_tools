import React from 'react'
import NewTrade from './NewTrade';
import Trade from './Trade';
import ShareTrades from './ShareTrades';
import { TradeSimulator } from './sim/TradeSimulator';

const options = ['アイテム破棄', 'アイテム手渡し', '食事', 'PS送付', 'アイテム送付', 'アイテム購入', '合成', '作製', '料理', '付加']

function compare_trade(a, b) {
   const typeIdA = options.findIndex(option => option === a.type);
   const typeIdB = options.findIndex(option => option === b.type);
   if (typeIdA != typeIdB) {
      return typeIdA - typeIdB;
   }
   if (a.eno != b.eno) {
      return a.eno - b.eno;
   }
   return a.id - b.id;
}

function group_trades(trades) {
   const ret = [];
   let prev_type = null;
   trades.forEach(trade => {
      if (prev_type !== trade.type) {
         ret.push([]);
         prev_type = trade.type;
      }
      ret[ret.length - 1].push(trade);
   });
   return ret;
}

export default class Trades extends React.Component {
   constructor(...args) {
      super(...args);
      this.state = {
         originalTrades: [],
         trades: [],
         tradeType: 'アイテム破棄',
      };
   }

   changeTrades(newTrades) {
      newTrades.sort(compare_trade);
      const sim = new TradeSimulator(this.props.players);
      const finalTrades = [];
      newTrades.forEach(trade => {
         finalTrades.push(sim.apply(trade));
      });
      this.setState({
         originalTrades: newTrades,
         trades: finalTrades,
      });
      this.props.onChangeFinalState(sim.players());

   }

   handleAddTrade(newTrade) {
      this.changeTrades([...this.state.originalTrades, newTrade]);
   }

   handleRemoveTrade(index) {
      this.changeTrades(this.state.originalTrades.filter((_, i) => i !== index));
   }

   handleChangeTradeType(e) {
      this.setState({
         tradeType: e.target.value,
      });
   }

   render() {
      return (
         <div className="trades">
            <div>取引一覧</div>
            {group_trades(this.state.trades).map((trades, i) => <div key={i} className="trade-group">
               {trades.map((trade, j) => <Trade key={j} onRemoveTrade={this.handleRemoveTrade.bind(this)} index={i} trade={trade} players={this.props.players} />)}
            </div>)}
            <div className="new-trade">
               <div>取引追加</div>
               <select value={this.state.tradeType} onChange={this.handleChangeTradeType.bind(this)}>
                  {options.map(option => <option key={option} value={option}>{option}</option>)}
               </select>
               <NewTrade type={this.state.tradeType} onCreate={this.handleAddTrade.bind(this)} players={this.props.players} />
            </div>
            <ShareTrades trades={this.state.originalTrades} onChangeTrades={this.changeTrades.bind(this)} />
         </div>
      );
   }
}
import React from 'react'
import NewTrade from './NewTrade';
import Trade from './Trade';
import ShareTrades, { sanitize } from './ShareTrades';
import { TradeSimulator } from './sim/TradeSimulator';
import PlayerSelector from './form/PlayerSelector';

const options = ['アイテム破棄', ['アイテム手渡し', 'アイテム手渡し(外部から)'], '食事', 'PS送付', ['アイテム送付', 'アイテム送付(外部から)'], 'アイテム購入', '合成', '作製', '料理', '付加']

function getTypeId(type) {
   return options.findIndex(option => option instanceof Array ? option.includes(type) : option === type);
}

function compare_trade(a, b) {
   const typeIdA = getTypeId(a.type);
   const typeIdB = getTypeId(b.type);
   if (typeIdA != typeIdB) {
      return typeIdA - typeIdB;
   }
   if (a.eno != b.eno) {
      return a.eno - b.eno;
   }
   return a.id - b.id;
}

function group_trades(trades, filterPlayer, showRelated) {
   const ret = [];
   let prevTypeId = null;
   trades
      .filter(trade => {
         let ok = true;
         if (filterPlayer) {
            ok = trade.eno === filterPlayer;
            if (showRelated) {
               ok = ok || (trade.targetEno === filterPlayer);
            }
         }
         return ok;
      })
      .forEach(trade => {
         const typeId = getTypeId(trade.type);
         if (prevTypeId !== typeId) {
            ret.push([]);
            prevTypeId = typeId;
         }
         ret[ret.length - 1].push(trade);
      });
   return ret;
}

function normalizeTradeType(type) {
   const opt = options.find(opt => opt instanceof Array ? opt.includes(type) : opt === type);
   if (opt) {
      return opt instanceof Array ? opt[0] : opt;
   } else {
      console.error('Unknown type: ' + type);
      return type;
   }

}

export default class Trades extends React.Component {
   constructor(...args) {
      super(...args);
      this.state = {
         originalTrades: [],
         trades: [],
         tradeType: 'アイテム破棄',
         filterPlayer: null,
         showRelated: false,
      };
   }

   componentDidMount() {
      if (localStorage) {
         const tradesJson = localStorage.getItem('trades');
         if (tradesJson) {
            this.changeTrades(sanitize(JSON.parse(tradesJson)));
         }
      }

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
      if (localStorage) {
         localStorage.setItem('trades', JSON.stringify(newTrades));
      }
   }

   handleAddTrade(newTrade) {
      this.changeTrades([...this.state.originalTrades, newTrade]);
   }

   handleRemoveTrade(id) {
      this.changeTrades(this.state.originalTrades.filter(trade => trade.id !== id));
   }

   handleChangeTradeType(e) {
      this.setState({
         tradeType: e.target.value,
      });
   }

   handleChangePlayerFilter(filterPlayer) {
      this.setState({ filterPlayer });
   }

   handleToggleShowRelated(e) {
      const showRelated = e.target.checked;
      console.log(showRelated);
      this.setState({ showRelated });
   }

   render() {
      return (
         <div className="trades">
            <div className="trades-header">
               <div className="trades-title">取引一覧</div>
               <div className="trades-filter">
                  <PlayerSelector value={this.state.filterPlayer} onChange={this.handleChangePlayerFilter.bind(this)} players={this.props.players} allowDeselect defaultOption="全表示" />
               </div>
               <div className="trades-filter">
                  <input type="checkbox" checked={this.state.showRelated} onChange={this.handleToggleShowRelated.bind(this)} />
                  <label>関係する取引も表示</label>
               </div>
            </div>
            {group_trades(this.state.trades, this.state.filterPlayer, this.state.showRelated).map((trades, i) => <div key={i} className="trade-group">
               <div className="trade-group-header">{normalizeTradeType(trades[0].type)}</div>
               {trades.map(trade => <Trade key={trade.id} onRemoveTrade={this.handleRemoveTrade.bind(this)} trade={trade} players={this.props.players} />)}
            </div>)}
            <div className="new-trade">
               <div>取引追加</div>
               <select value={this.state.tradeType} onChange={this.handleChangeTradeType.bind(this)}>
                  {options.flat().map(option => <option key={option} value={option}>{option}</option>)}
               </select>
               <NewTrade type={this.state.tradeType} onCreate={this.handleAddTrade.bind(this)} players={this.props.players} />
            </div>
            <ShareTrades trades={this.state.originalTrades} onChangeTrades={this.changeTrades.bind(this)} />
         </div>
      );
   }
}
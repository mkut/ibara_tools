import React from 'react'
import Players from './Players'
import Trades from './Trades'
import { players } from './fixtures';

export default class App extends React.Component {
   constructor(...args) {
      super(...args);
      this.state = {
         players: players,
         finalState: players,
      };
   }

   handleChangeFinalState(newValue) {
      this.setState({
         finalState: newValue,
      });
   }

   render() {
      return <div>
         <Players players={this.state.players} />
         <Trades players={this.state.players} onChangeFinalState={this.handleChangeFinalState.bind(this)} />
         <Players players={this.state.finalState} />
      </div>
   }

}
import React from 'react'

export default class PlayerName extends React.Component {
   playerName(eno) {
      const player = this.props.players.find(player => player.eno === eno);
      return player ? `ENO#${eno}(${player.name})` : `ENO#${eno}`;
   }

   render() {
      const { eno, target } = this.props;
      return <span className={target ? 'target-player-name' : 'player-name'}>{this.playerName(eno)}</span>;
   }
}
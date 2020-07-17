import React from 'react'

import PlayerName from './PlayerName';

export default class ItemSlotName extends React.Component {
   playerName(eno) {
      const player = this.props.players.find(player => player.eno === eno);
      return player ? `ENO#${eno}(${player.name})` : `ENO#${eno}`;
   }

   render() {
      const { targetEno, targetItemId } = this.props;
      return <span>
         <PlayerName eno={targetEno} players={this.props.players} target />
         {targetItemId && <span>の<span className="item-slot-name">Item#{targetItemId}</span></span>}
      </span>;
   }
}
import React from 'react'
import Player from './Player'

export default class Players extends React.Component {
   render() {
      return (
         <div className="container">
            {this.props.players.map(player => <Player key={player.eno} player={player} />)}
         </div>
      );
   }

}
import React from 'react'

export default class PlayerSelector extends React.Component {
   handleChange(e) {
      this.props.onChange(Number(e.target.value));
   }

   render() {
      return (
         <select value={this.props.value || ''} onChange={this.handleChange.bind(this)}>
            <option disabled value="">選んでください</option>
            {this.props.players.map(player => <option key={player.eno} value={player.eno}>{player.name}</option>)}
         </select>
      );
   }
}
import React from 'react'

export default class PlayerSelector extends React.Component {
   constructor(args) {
      super(args);
      this.state = {
         selectingOther: false,
         customValue: '',
      };
   }

   handleSelect(e) {
      const value = e.target.value;
      this.setState({
         selectingOther: value === '-1',
      }, () => {
         this.handleChange(value === '-1' ? Number(this.state.customValue) : Number(value));
      });
   }

   handleInput(e) {
      const value = e.target.value;
      this.setState({
         customValue: value,
      }, () => this.handleChange(Number(value)));
   }

   handleChange(newValue) {
      if (!isNaN(newValue)) {
         this.props.onChange(newValue);
      }
   }

   render() {
      return (
         <div>
            <select value={this.state.selectingOther ? '-1' : (this.props.value || '')} onChange={this.handleSelect.bind(this)}>
               <option disabled={!this.props.allowDeselect} value="">{this.props.defaultOption || '選んでください'}</option>
               {this.props.players.map(player => <option key={player.eno} value={player.eno}>{player.name}</option>)}
               {!this.props.memberOnly && <option value="-1">その他</option>}
            </select>
            {this.state.selectingOther && <div>
               <label>ENO: </label>
               <input type="number" value={this.state.customValue} onChange={this.handleInput.bind(this)} />
            </div>}
         </div>
      );
   }
}
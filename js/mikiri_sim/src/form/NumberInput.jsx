import React from 'react'

export default class NumberInput extends React.Component {
   handleChange(e) {
      let newValue = Number(e.target.value);
      if (newValue === 0) {
         newValue = null;
      }
      this.props.onChange(newValue);
   }

   render() {
      return (
         <input
            type="number"
            value={this.props.value || ''}
            onChange={this.handleChange.bind(this)}
         />
      );
   }
}
import React from 'react'

export default class TextInput extends React.Component {
   handleChange(e) {
      let newValue = e.target.value;
      if (newValue === '') {
         newValue = null;
      }
      this.props.onChange(newValue);
   }

   render() {
      return (
         <input
            value={this.props.value || ''}
            onChange={this.handleChange.bind(this)}
         />
      );
   }
}
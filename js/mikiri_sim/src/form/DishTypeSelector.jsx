import React from 'react'

export default class DishTypeSelector extends React.Component {
   handleChange(e) {
      this.props.onChange(e.target.value);
   }

   render() {
      return (
         <select value={this.props.value || ''} onChange={this.handleChange.bind(this)}>
            <option disabled value="">選んでください</option>
            <option value="料理">料理</option>
            <option value="魔香">魔香</option>
            <option value="賄飯">賄飯</option>
         </select>
      );
   }
}
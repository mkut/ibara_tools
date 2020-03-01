import React from 'react'

export default class ItemTypeSelector extends React.Component {
   handleChange(e) {
      this.props.onChange(e.target.value);
   }

   render() {
      return (
         <select value={this.props.value || ''} onChange={this.handleChange.bind(this)}>
            <option disabled value="">選んでください</option>
            <option value="material">素材</option>
            <option value="food">食材</option>
            <option value="equipment">装備</option>
            <option value="dish">料理</option>
         </select>
      );
   }
}
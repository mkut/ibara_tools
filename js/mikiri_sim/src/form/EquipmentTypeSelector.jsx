import React from 'react'
import { equipmentTypes } from '../gamedata/ItemTypes';

export default class EquipmentTypeSelector extends React.Component {
   handleChange(e) {
      this.props.onChange(e.target.value);
   }

   render() {
      return (
         <select value={this.props.value || ''} onChange={this.handleChange.bind(this)}>
            <option disabled value="">選んでください</option>
            {equipmentTypes.map(itemType => <option value={itemType}>{itemType}</option>)}
         </select>
      );
   }
}
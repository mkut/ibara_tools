import React from 'react'

export default class EquipmentTypeSelector extends React.Component {
   handleChange(e) {
      this.props.onChange(e.target.value);
   }

   render() {
      return (
         <select value={this.props.value || ''} onChange={this.handleChange.bind(this)}>
            <option disabled value="">選んでください</option>
            <option value="武器">武器</option>
            <option value="大砲">大砲</option>
            <option value="呪器">呪器</option>
            <option value="防具">防具</option>
            <option value="法衣">法衣</option>
            <option value="装飾">装飾</option>
            <option value="魔晶">魔晶</option>
         </select>
      );
   }
}
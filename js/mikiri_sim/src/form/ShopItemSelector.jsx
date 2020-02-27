import React from 'react'
import { shopItems } from '../fixtures';

export default class ShopItemSelector extends React.Component {
   handleChange(e) {
      const itemName = e.target.value;
      const item = shopItems.find(item => item.name === itemName);
      this.props.onChange(item);
   }

   render() {
      return (
         <select value={this.props.value ? this.props.value.name : ''} onChange={this.handleChange.bind(this)}>
            <option disabled value="">選んでください</option>
            {shopItems.map(item => <option key={item.name} value={item.name}>{item.name}</option>)}
         </select>
      );
   }
}
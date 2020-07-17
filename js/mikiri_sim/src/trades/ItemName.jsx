import React from 'react'

export default class ItemName extends React.Component {
   displayItem(itemId, item) {
      return item ? `Item#${itemId}(${item.name})` : `Item#${itemId}`;
   }

   render() {
      const { itemId, item, itemName } = this.props;
      if (itemId) {
         return <span className="item-name">{this.displayItem(itemId, item)}</span>;
      } else if (itemName) {
         return <span className="item-name">{itemName}</span>;
      } else {
         return <span className="item-name">ERROR ITEM NAME</span>
      }
   }
}
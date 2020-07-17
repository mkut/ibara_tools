import React from 'react'

export default class Item extends React.Component {
   render () {
      if (!this.props.item) {
         return null;
      }
      const { name, special, type } = this.props.item;
      return (
         <span className={special ? 'special-item' : ''}>
            {name}
         </span>
      );
   }
}
import React from 'react'
import ItemEffect from '../common/ItemEffect';

export default class Location extends React.Component {
   render() {
      return (
         <tr>
            <td>{this.props.location.eno}</td>
            <td>{this.props.location.playerName}</td>
            <td>{this.props.location.index}</td>
            <td><span className="special-item">{this.props.location.special ? '特殊アイテム' : ''}</span></td>
         </tr>
      );
   }
}
import React from 'react'
import ItemEffect from '../common/ItemEffect';

export default class Location extends React.Component {
   render() {
      return (
         <tr>
            <td><a target="_blank" rel="noopener noreferrer" href={`http://lisge.com/ib/k/now/r${this.props.location.eno}.html`}>{this.props.location.eno}</a></td>
            <td>{this.props.location.playerName}</td>
            <td>{this.props.location.index}</td>
            <td><span className="special-item">{this.props.location.special ? '特殊アイテム' : ''}</span></td>
         </tr>
      );
   }
}
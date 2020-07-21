import React from 'react'
import ItemEffect from '../common/ItemEffect';
import Locations from './Locations';
import { itemData } from '../fixtures';

export default class Material extends React.Component {
   constructor(...args) {
      super(...args);
      this.state = {
         expanded: false,
      };
   }

   handleToggleExpanded() {
      this.setState({
         expanded: !this.state.expanded,
      });
   }

   render() {
      const ret = [];
      ret.push(
         <tr style={this.props.visible ? {} : {display: 'none'}} className="material-row" key="0" onClick={this.handleToggleExpanded.bind(this)}>
            <td>{this.props.data.locations.length}</td>
            <td>{this.props.data.item.name}</td>
            <td>{this.props.data.item.power}</td>
            <td><ItemEffect effect={this.props.data.item.effect1} /></td>
            <td><ItemEffect effect={this.props.data.item.effect2} /></td>
            <td><ItemEffect effect={this.props.data.item.effect3} /></td>
            <td>{itemData.find(row => row['アイテム名'] === this.props.data.item.name)['可能強度範囲']}</td>
         </tr>
      );
      if (this.state.expanded) {
         ret.push(
            <tr key="1">
               <td colSpan="6">
                  <Locations locations={this.props.data.locations}/>
               </td>
            </tr>
         );
      }
      return ret;
   }
}
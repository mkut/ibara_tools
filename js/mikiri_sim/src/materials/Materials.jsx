import React from 'react'
import Material from './Material';
import TextInput from '../form/TextInput';

class MaterialsMain extends React.Component {
   constructor(...args) {
      super(...args);
      this.state = {
         filter: '',
      };
   }

   handleChangeFilter(newValue) {
      this.setState({
         filter: newValue,
      });
   }

   getVisible(itemName) {
      if (!this.state.filter || this.state.filter === '') {
         return true;
      }
      if (itemName.search(this.state.filter) >= 0) {
         return true;
      }
      if (this.props.materials[itemName].item.effect1.name.search(this.state.filter) >= 0) {
         return true;
      }
      if (this.props.materials[itemName].item.effect2.name.search(this.state.filter) >= 0) {
         return true;
      }
      if (this.props.materials[itemName].item.effect3.name.search(this.state.filter) >= 0) {
         return true;
      }
      return false;
   }

   render() {
      return (
         <div className="materials-pane">
            <div>
               検索: 
               <TextInput value={this.state.filter} onChange={this.handleChangeFilter.bind(this)} />
            </div>
            <table className="materials-table">
               <thead>
                  <tr>
                     <th>個数</th>
                     <th>アイテム名</th>
                     <th>強さ</th>
                     <th>{this.props.itemType === '素材' ? '武器' : '効果1'}</th>
                     <th>{this.props.itemType === '素材' ? '防具' : '効果2'}</th>
                     <th>{this.props.itemType === '素材' ? '装飾' : '効果3'}</th>
                  </tr>
               </thead>
               <tbody>
                  {Object.keys(this.props.materials).map(itemName => <Material visible={this.getVisible(itemName)} key={itemName} data={this.props.materials[itemName]} />)}
               </tbody>
            </table>
         </div>
      )
   }
}

export default class Materials extends React.Component {
   render() {
      const materials = {};
      this.props.players.forEach(player => {
         player.items.forEach((item, idx) => {
            if (item !== null && item.type === this.props.itemType) {
               if (!materials[item.name]) {
                  materials[item.name] = {
                     item: item,
                     locations: [],
                  };
               }
               materials[item.name].locations.push({
                  eno: player.eno,
                  playerName: player.name,
                  index: idx + 1,
                  special: item.special,
               });
            }
         });
      });
      return <MaterialsMain materials={materials} itemType={this.props.itemType} />
   }
}
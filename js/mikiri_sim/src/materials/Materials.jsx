import React from 'react'
import Material from './Material';
import TextInput from '../form/TextInput';

function materialSortFunc(material) {
   let name = material.item.name;
   let power = material.item.power;
   let plus = 0;
   const m = material.item.name.match(/^(.*)\+(\d+)$/);
   if (m) {
      plus = Number(m[2]);
      power -= plus * 5;
      name = m[1];
   }
   console.log(name, power, plus);
   return { name, power, plus };
}

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

   getVisible(material) {
      if (!this.state.filter || this.state.filter === '') {
         return true;
      }
      if (material.item.name.search(this.state.filter) >= 0) {
         return true;
      }
      if (material.item.effect1.name.search(this.state.filter) >= 0) {
         return true;
      }
      if (material.item.effect2.name.search(this.state.filter) >= 0) {
         return true;
      }
      if (material.item.effect3.name.search(this.state.filter) >= 0) {
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
                     <th>合成強度</th>
                  </tr>
               </thead>
               <tbody>
                  {this.props.materials.map(material => <Material visible={this.getVisible(material)} key={material.item.name} data={material} />)}
               </tbody>
            </table>
         </div>
      )
   }
}

export default class Materials extends React.Component {
   render() {
      const materialsMap = {};
      this.props.players.forEach(player => {
         player.items.forEach((item, idx) => {
            if (item !== null && item.type === this.props.itemType) {
               if (!materialsMap[item.name]) {
                  materialsMap[item.name] = {
                     item: item,
                     locations: [],
                  };
               }
               materialsMap[item.name].locations.push({
                  eno: player.eno,
                  playerName: player.name,
                  index: idx + 1,
                  special: item.special,
               });
            }
         });
      });
      const materials = Object.values(materialsMap);
      materials.sort((a, b) => {
         const aa = materialSortFunc(a);
         const bb = materialSortFunc(b);
         if (aa.power !== bb.power) return aa.power > bb.power ? -1 : 1;
         if (aa.name !== bb.name) return aa.name < bb.name ? -1 : 1;
         return aa.plus > bb.plus ? -1 : 1;
      });
      return <MaterialsMain materials={materials} itemType={this.props.itemType} />
   }
}
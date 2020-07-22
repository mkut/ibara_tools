import React from 'react'
import ItemEffect from '../common/ItemEffect';
import { material_strength } from '../fixtures';

export default class EquipmentTable extends React.Component {
   render() {
      return (
         <div className="equipment-group">
            <div className="item-type-header">{this.props.itemType}</div>
            <table className="equipments-table">
               <thead>
                  <tr>
                     <th>ItemNo</th>
                     <th>アイテム名</th>
                     <th>種類</th>
                     <th>強さ</th>
                     <th>効果1</th>
                     <th>効果2</th>
                     <th>効果3</th>
                     {this.props.itemType === '武器' && <th>射程</th>}
                     <th>合成強度</th>
                  </tr>
               </thead>
               <tbody>
                  {this.props.equipments.map(equipment => (
                     <tr key={equipment.index}>
                        <td>{equipment.index}</td>
                        <td>{equipment.item.name}</td>
                        <td>{equipment.item.type}</td>
                        <td>{equipment.item.power}</td>
                        <td><ItemEffect effect={equipment.item.effect1} /></td>
                        <td><ItemEffect effect={equipment.item.effect2} /></td>
                        <td><ItemEffect effect={equipment.item.effect3} /></td>
                        {this.props.itemType === '武器' && <td>{equipment.item.range}</td>}
                        <td>{material_strength(equipment.item.material) || 'No data'}({equipment.item.material})</td>
                     </tr>
                  ))}
               </tbody>
            </table>
         </div>
      );
   }
}

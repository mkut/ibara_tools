import React from 'react'
import { isEquipment, isWeapon, isArmor, isAccessory, isDish } from '../gamedata/ItemTypes';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';
import 'react-tabs/style/react-tabs.css';
import EquipmentTable from './EquipmentTable';

class EquipmentList extends React.Component {
   render() {
      return (
         <div>
            <EquipmentTable itemType="武器" equipments={this.props.equipments.weapons} />
            <EquipmentTable itemType="防具" equipments={this.props.equipments.armors} />
            <EquipmentTable itemType="装飾" equipments={this.props.equipments.accessories} />
            <EquipmentTable itemType="料理" equipments={this.props.equipments.dishes} />
         </div>
      );
   }
}

class EquipmentsMain extends React.Component {
   render() {
      return (
         <Tabs>
            <TabList>
               {this.props.players.map(player => <Tab key={player.eno}>{player.name}</Tab>)}
            </TabList>
            {this.props.players.map(player => (
               <TabPanel key={player.eno}>
                  <EquipmentList equipments={this.props.equipments[player.eno]} />
               </TabPanel>
            ))}
         </Tabs>
      )
   }
}

export default class Equipments extends React.Component {
   render() {
      const equipments = {};
      this.props.players.forEach(player => {
         equipments[player.eno] = {
            weapons: [],
            armors: [],
            accessories: [],
            dishes: [],
         };
         player.items.forEach((item, idx) => {
            if (item !== null && isEquipment(item.type)) {
               if (isWeapon(item.type)) {
                  equipments[player.eno].weapons.push({ index: idx + 1, item });
               } else if (isArmor(item.type)) {
                  equipments[player.eno].armors.push({ index: idx + 1, item });
               } else if (isAccessory(item.type)) {
                  equipments[player.eno].accessories.push({ index: idx + 1, item });
               }
            } else if (item != null && isDish(item.type)) {
               equipments[player.eno].dishes.push({ index: idx + 1, item });
            }
         });
         equipments[player.eno].weapons.sort((a, b) => b.item.power - a.item.power);
         equipments[player.eno].armors.sort((a, b) => b.item.power - a.item.power);
         equipments[player.eno].accessories.sort((a, b) => b.item.power - a.item.power);
         equipments[player.eno].dishes.sort((a, b) => b.item.power - a.item.power);
      });
      return <EquipmentsMain players={this.props.players} equipments={equipments} />
   }
}
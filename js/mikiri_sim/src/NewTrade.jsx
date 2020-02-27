import React from 'react'
import PlayerSelector from './form/PlayerSelector';
import NumberInput from './form/NumberInput';
import ShopItemSelector from './form/ShopItemSelector';

export default class NewTrade extends React.Component {
   constructor(...args) {
      super(...args);
      this.idmax = 0;
      this.state = {
         eno: null,
         itemId: null,
         itemId2: null,
         targetEno: null,
         ps: null,
         shopItem: null,
      };
   }

   handleAddTrade(e) {
      e.preventDefault();
      switch (this.props.type) {
         case 'アイテム破棄':
         case '食事':
            this.props.onCreate({
               type: this.props.type,
               eno: this.state.eno,
               itemId: this.state.itemId,
               id: ++this.idmax,
            });
            break;
         case 'アイテム手渡し':
         case 'アイテム送付':
            this.props.onCreate({
               type: this.props.type,
               eno: this.state.eno,
               itemId: this.state.itemId,
               targetEno: this.state.targetEno,
               id: ++this.idmax,
            });
            break;
         case 'PS送付':
            this.props.onCreate({
               type: this.props.type,
               eno: this.state.eno,
               targetEno: this.state.targetEno,
               ps: this.state.ps,
               id: ++this.idmax,
            });
            break;
         case 'アイテム購入':
            this.props.onCreate({
               type: this.props.type,
               eno: this.state.eno,
               shopItem: this.state.shopItem,
               id: ++this.idmax,
            });
            break;
         case '合成':
         case '付加':
            this.props.onCreate({
               type: this.props.type,
               eno: this.state.eno,
               targetEno: this.state.targetEno,
               itemId: this.state.itemId,
               itemId2: this.state.itemId2,
               id: ++this.idmax,
            });
            break;
         case '作製':
         case '料理':
            this.props.onCreate({
               type: this.props.type,
               eno: this.state.eno,
               targetEno: this.state.targetEno,
               itemId: this.state.itemId,
               id: ++this.idmax,
            });
            break;
      }
   }

   handleSetEno(newValue) {
      this.setState({
         eno: newValue,
      });
   }

   handleSetItemId(newValue) {
      this.setState({
         itemId: newValue,
      });
   }

   handleSetItemId2(newValue) {
      this.setState({
         itemId2: newValue,
      });
   }

   handleSetTargetEno(newValue) {
      this.setState({
         targetEno: newValue,
      });
   }

   handleSetPs(newValue) {
      this.setState({
         ps: newValue,
      });
   }

   handleSetShopItem(newValue) {
      this.setState({
         shopItem: newValue,
      });
   }

   checkSubmittable() {
      switch (this.props.type) {
         case 'アイテム破棄':
         case '食事':
            return this.state.eno && this.state.itemId;
         case 'アイテム手渡し':
         case 'アイテム送付':
            return this.state.eno && this.state.itemId && this.state.targetEno;
         case 'PS送付':
            return this.state.eno && this.state.targetEno && this.state.ps;
         case 'アイテム購入':
            return this.state.eno && this.state.shopItem;
         case '合成':
         case '付加':
            return this.state.eno && this.state.targetEno && this.state.itemId && this.state.itemId2;
         case '作製':
         case '料理':
            return this.state.eno && this.state.targetEno && this.state.itemId;
      }
      return false;
   }

   render() {
      const trs = []
      switch (this.props.type) {
         case 'アイテム破棄':
         case '食事':
            trs.push(
               <tr key="eno">
                  <th>誰が</th>
                  <td><PlayerSelector value={this.state.eno} onChange={this.handleSetEno.bind(this)} players={this.props.players} /></td>
               </tr>
            );
            trs.push(
               <tr key="itemId">
                  <th>何を(ItemID)</th>
                  <td><NumberInput value={this.state.itemId} onChange={this.handleSetItemId.bind(this)} /></td>
               </tr>
            );
            break;
         case 'アイテム手渡し':
         case 'アイテム送付':
            trs.push(
               <tr key="eno">
                  <th>誰が</th>
                  <td><PlayerSelector value={this.state.eno} onChange={this.handleSetEno.bind(this)} players={this.props.players} /></td>
               </tr>
            );
            trs.push(
               <tr key="targetEno">
                  <th>誰に(ENO)</th>
                  <td><NumberInput value={this.state.targetEno} onChange={this.handleSetTargetEno.bind(this)} /></td>
               </tr>
            );
            trs.push(
               <tr key="itemId">
                  <th>何を(ItemID)</th>
                  <td><NumberInput value={this.state.itemId} onChange={this.handleSetItemId.bind(this)} /></td>
               </tr>
            );
            break;
         case 'PS送付':
            trs.push(
               <tr key="eno">
                  <th>誰が(ENO)</th>
                  <td><NumberInput value={this.state.eno} onChange={this.handleSetEno.bind(this)} /></td>
               </tr>
            );
            trs.push(
               <tr key="targetEno">
                  <th>誰に(ENO)</th>
                  <td><NumberInput value={this.state.targetEno} onChange={this.handleSetTargetEno.bind(this)} /></td>
               </tr>
            );
            trs.push(
               <tr key="ps">
                  <th>いくら(PS)</th>
                  <td><NumberInput value={this.state.ps} onChange={this.handleSetPs.bind(this)} /></td>
               </tr>
            );
            break;
         case 'アイテム購入':
            trs.push(
               <tr key="eno">
                  <th>誰が</th>
                  <td><PlayerSelector value={this.state.eno} onChange={this.handleSetEno.bind(this)} players={this.props.players} /></td>
               </tr>
            );
            trs.push(
               <tr key="shopItem">
                  <th>何を</th>
                  <td><ShopItemSelector value={this.state.shopItem} onChange={this.handleSetShopItem.bind(this)} /></td>
               </tr>
            );
            break;
         case '合成':
         case '付加':
            trs.push(
               <tr key="eno">
                  <th>誰が(ENO)</th>
                  <td><NumberInput value={this.state.eno} onChange={this.handleSetEno.bind(this)} /></td>
               </tr>
            );
            trs.push(
               <tr key="targetEno">
                  <th>誰の</th>
                  <td><PlayerSelector value={this.state.targetEno} onChange={this.handleSetTargetEno.bind(this)} players={this.props.players} /></td>
               </tr>
            );
            trs.push(
               <tr key="itemId">
                  <th>何に(ベースのItemID)</th>
                  <td><NumberInput value={this.state.itemId} onChange={this.handleSetItemId.bind(this)} /></td>
               </tr>
            );
            trs.push(
               <tr key="itemId2">
                  <th>何を(ItemID)</th>
                  <td><NumberInput value={this.state.itemId2} onChange={this.handleSetItemId2.bind(this)} /></td>
               </tr>
            );
            break;
         case '作製':
         case '料理':
            trs.push(
               <tr key="eno">
                  <th>誰が(ENO)</th>
                  <td><NumberInput value={this.state.eno} onChange={this.handleSetEno.bind(this)} /></td>
               </tr>
            );
            trs.push(
               <tr key="targetEno">
                  <th>誰の</th>
                  <td><PlayerSelector value={this.state.targetEno} onChange={this.handleSetTargetEno.bind(this)} players={this.props.players} /></td>
               </tr>
            );
            trs.push(
               <tr key="itemId">
                  <th>何から(ItemID)</th>
                  <td><NumberInput value={this.state.itemId} onChange={this.handleSetItemId.bind(this)} /></td>
               </tr>
            );
      }
      return (
         <form onSubmit={this.handleAddTrade.bind(this)} >
            <table>
               <tbody>
                  {trs}
                  <tr>
                     <th></th>
                     <td><button type="submit" disabled={!this.checkSubmittable()}>追加</button></td>
                  </tr>
               </tbody>
            </table>
         </form>
      );
   }
}
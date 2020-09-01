import React from 'react'

import PlayerName from './PlayerName';
import ItemName from './ItemName';
import ItemSlotName from './ItemSlotName';

export default class Trade extends React.Component {
   playerName(eno) {
      const player = this.props.players.find(player => player.eno === eno);
      return player ? `ENO#${eno}(${player.name})` : `ENO#${eno}`;
   }

   displayItem(itemId, item) {
      return item ? `Item#${itemId}(${item.name})` : `Item#${itemId}`;
   }

   displayItemSlot(eno, itemId) {
      return itemId ? `${this.playerName(eno)}のItem#${itemId}` : this.playerName(eno);
   }

   handleClickRemoveButton() {
      this.props.onRemoveTrade(this.props.trade.id);
   }

   render() {
      const { type, eno, targetEno, itemId, itemId2, shopItem, ps, warning, item, item2, targetItemId, itemName, itemType } = this.props.trade;
      let text = 'unknown trade type';
      switch (type) {
         case 'アイテム破棄':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <ItemName item={item} itemId={itemId} /> を破棄する。
               </span>
            );
            break;
         case 'アイテム手渡し':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <ItemSlotName targetEno={targetEno} targetItemId={targetItemId} players={this.props.players} /> に&nbsp;
                  <ItemName item={item} itemId={itemId} /> を手渡しする。
               </span>
            );
            break;
         case 'アイテム手渡し(外部から)':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <ItemSlotName targetEno={targetEno} targetItemId={targetItemId} players={this.props.players} /> に&nbsp;
                  <ItemName itemName={itemName} /> を手渡しする。
               </span>
            );
            break;
         case '食事':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <ItemName item={item} itemId={itemId} /> を食べる。
               </span>
            );
            break;
         case 'PS送付':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <PlayerName eno={targetEno} players={this.props.players} target /> に&nbsp;
                  <span className="ps-name">{ps}PS</span> 送付する。
               </span>
            );
            break;
         case 'アイテム送付':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <ItemSlotName targetEno={targetEno} targetItemId={targetItemId} players={this.props.players} /> に&nbsp;
                  <ItemName item={item} itemId={itemId} /> を送付する。
               </span>
            );
            break;
         case 'アイテム送付(外部から)':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <ItemSlotName targetEno={targetEno} targetItemId={targetItemId} players={this.props.players} /> に&nbsp;
                  <ItemName itemName={itemName} /> を送付する。
               </span>
            );
            break;
         case 'アイテム購入':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <ItemSlotName targetEno={eno} targetItemId={targetItemId} players={this.props.players} /> に&nbsp;
                  <ItemName itemName={shopItem.name} /> を購入する。
               </span>
            );
            break;
         case '合成':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <PlayerName eno={targetEno} players={this.props.players} target /> の&nbsp;
                  <ItemName item={item} itemId={itemId} /> に&nbsp;
                  <ItemName item={item2} itemId={itemId2} /> を合成する。
               </span>
            );
            break;
         case '作製':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <PlayerName eno={targetEno} players={this.props.players} target /> の&nbsp;
                  <ItemName item={item} itemId={itemId} /> で&nbsp;
                  <span className="item-type">{itemType}</span> を作製する。
               </span>
            );
            break;
         case '料理':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <PlayerName eno={targetEno} players={this.props.players} target /> の&nbsp;
                  <ItemName item={item} itemId={itemId} /> で料理する。
               </span>
            );
            break;
         case '付加':
            text = (
               <span>
                  <PlayerName eno={eno} players={this.props.players} /> が&nbsp;
                  <PlayerName eno={targetEno} players={this.props.players} target /> の&nbsp;
                  <ItemName item={item} itemId={itemId} /> に&nbsp;
                  <ItemName item={item2} itemId={itemId2} /> を付加する。
               </span>
            );
            break;
      }
      return (
         <div className="trade">
            <label>
               <input type="checkbox" className="checkbox-input" />
               <span className="checkbox-parts">{text}</span>
               <span className="warning">{warning}</span>
            </label>
            <button onClick={this.handleClickRemoveButton.bind(this)}>削除</button>
         </div>
      );
   }
}
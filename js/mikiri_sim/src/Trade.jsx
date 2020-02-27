import React from 'react'

export default class Trades extends React.Component {
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
      this.props.onRemoveTrade(this.props.index);
   }

   render() {
      const { type, eno, targetEno, itemId, itemId2, shopItem, ps, warning, item, item2, targetItemId } = this.props.trade;
      let text = 'unknown trade type';
      switch (type) {
         case 'アイテム破棄':
            text = (
               <span>
                  {this.playerName(eno)} が {this.displayItem(itemId, item)} を破棄する。
               </span>
            );
            break;
         case 'アイテム手渡し':
            text = (
               <span>
                  {this.playerName(eno)} が {this.displayItemSlot(targetEno, targetItemId)} に {this.displayItem(itemId, item)} を手渡しする。
               </span>
            );
            break;
         case '食事':
            text = (
               <span>
                  {this.playerName(eno)} が {this.displayItem(itemId, item)} を食べる。
               </span>
            );
            break;
         case 'PS送付':
            text = (
               <span>
                  {this.playerName(eno)} が {this.playerName(targetEno)} に {ps}PS 送付する。
               </span>
            );
            break;
         case 'アイテム送付':
            text = (
               <span>
                  {this.playerName(eno)} が {this.displayItemSlot(targetEno, targetItemId)} に {this.displayItem(itemId, item)} を送付する。
               </span>
            );
            break;
         case 'アイテム購入':
            text = (
               <span>
                  {this.playerName(eno)} が {this.displayItemSlot(eno, targetItemId)} に {shopItem.name} を購入する。
               </span>
            );
            break;
         case '合成':
            text = (
               <span>
                  {this.playerName(eno)} が {this.playerName(targetEno)} の {this.displayItem(itemId, item)} に {this.displayItem(itemId2, item2)} を合成する。
               </span>
            );
            break;
         case '作製':
            text = (
               <span>
                  {this.playerName(eno)} が {this.playerName(targetEno)} の {this.displayItem(itemId, item)} で作製する。
               </span>
            );
            break;
         case '料理':
            text = (
               <span>
                  {this.playerName(eno)} が {this.playerName(targetEno)} の {this.displayItem(itemId, item)} で料理する。
               </span>
            );
            break;
         case '付加':
            text = (
               <span>
                  {this.playerName(eno)} が {this.playerName(targetEno)} の {this.displayItem(itemId, item)} に {this.displayItem(itemId2, item2)} を付加する。
               </span>
            );
            break;
      }
      return (
         <div className="trade">
            {text}
            <span className="warning">{warning}</span>
            <button onClick={this.handleClickRemoveButton.bind(this)}>削除</button>
         </div>
      );
   }
}
import { isFood, isDish, isEquipment, isMaterial } from '../../gamedata/ItemTypes';

export class TradeSimulator {
   constructor(players) {
      this.state = {};
      players.forEach(player => {
         this.state[player.eno] = {
            eno: player.eno,
            name: player.name,
            ps: player.ps,
            items: [...player.items],
         };
      });
   }

   trashItem(trade) {
      const player = this.state[trade.eno];
      if (!player) {
         return {...trade,
            // warning: '対象外のプレイヤーのアイテム破棄',
         }
      }
      const item = player.items[trade.itemId - 1];
      if (!item) {
         return {...trade,
            warning: '存在しないアイテムを破棄',
         }
      }
      player.items[trade.itemId - 1] = null;
      return {...trade,
         item: item,
      }
   }

   sendItem(trade) {
      const player = this.state[trade.eno];
      if (!player) {
         return {...trade,
            warning: '対象外のプレイヤーのアイテム送付/手渡し',
         }
      }
      const item = player.items[trade.itemId - 1];
      if (!item) {
         return {...trade,
            warning: '存在しないアイテム送付/手渡し',
         }
      }
      if (item.special) {
         return {...trade,
            item: item,
            warning: '特別なアイテム送付/手渡し',
         }
      }

      let targetItemId = null;
      const targetPlayer = this.state[trade.targetEno];
      if (targetPlayer) {
         for (let i = 0; i < targetPlayer.items.length; i++) {
            if (!targetPlayer.items[i]) {
               targetItemId = i + 1;
               break;
            }
         };
         if (!targetItemId) {
            targetItemId = targetPlayer.items.length + 1;
         }
         targetPlayer.items[targetItemId - 1] = item;
      }
      player.items[trade.itemId - 1] = null;

      return {...trade,
         item: item,
         targetItemId: targetItemId,
      };
   }

   sendItemFromOutside(trade) {
      const player = this.state[trade.eno];
      if (player) {
         return {...trade,
            warning: '対象内のプレイヤーのアイテム送付/手渡し(外部から)',
         }
      }
      const item = {
         type: trade.itemType,
         name: trade.itemName,
      }

      let targetItemId = null;
      const targetPlayer = this.state[trade.targetEno];
      if (!targetPlayer) {
         return {...trade,
            // warning: '対象外のプレイヤーへアイテム送付/手渡し(外部から)',
         }
      }
      for (let i = 0; i < targetPlayer.items.length; i++) {
         if (!targetPlayer.items[i]) {
            targetItemId = i + 1;
            break;
         }
      };
      if (!targetItemId) {
         targetItemId = targetPlayer.items.length + 1;
      }
      targetPlayer.items[targetItemId - 1] = item;

      return {...trade,
         item: item,
         targetItemId: targetItemId,
      };
   }

   eatItem(trade) {
      const player = this.state[trade.eno];
      if (!player) {
         return {...trade,
            // warning: '対象外のプレイヤーの食事',
         }
      }
      const item = player.items[trade.itemId - 1];
      if (!item) {
         return {...trade,
            warning: '存在しないアイテムを食事',
         }
      }
      if (!isDish(item.type) && !isFood(item.type)) {
         return {...trade,
            item: item,
            warning: '食べられないアイテムを食事',
         }
      }
      player.items[trade.itemId - 1] = null;
      return {...trade,
         item: item,
         warning: isFood(item.type) ? '調理前のアイテムを食事' : null,
      }
   }

   sendPs(trade) {
      const player = this.state[trade.eno];
      const targetPlayer = this.state[trade.targetEno];

      if (player) {
         if (player.ps < trade.ps) {
            return {...trade,
               warning: 'PS不足',
            };
         }
         player.ps -= trade.ps;
      }
      if (targetPlayer) {
         targetPlayer.ps += trade.ps;
      }

      return trade;
   }

   buyItem(trade) {
      const player = this.state[trade.eno];
      if (!player) {
         return {...trade,
            // warning: '対象外のプレイヤーのアイテム購入',
         }
      }

      if (player.ps < trade.shopItem.price) {
         return {...trade,
            warning: 'PS不足',
         };
      }
      player.ps -= trade.shopItem.price;

      let targetItemId = null;
      for (let i = 0; i < player.items.length; i++) {
         if (!player.items[i]) {
            targetItemId = i + 1;
            break;
         }
      };
      if (!targetItemId) {
         targetItemId = player.items.length + 1;
      }
      player.items[targetItemId - 1] = trade.shopItem;

      return {...trade,
         targetItemId: targetItemId,
      };
   }

   synthesize(trade) {
      const targetPlayer = this.state[trade.targetEno];
      if (!targetPlayer) {
         return {...trade,
            // warning: '対象外のプレイヤーに対する合成',
         }
      }
      const item = targetPlayer.items[trade.itemId - 1];
      const item2 = targetPlayer.items[trade.itemId2 - 1];
      if (!item) {
         return {...trade,
            item2: item2,
            warning: '存在しないアイテムに合成',
         }
      }
      if (!item2) {
         return {...trade,
            item: item,
            warning: '存在しないアイテムを合成',
         }
      }
      targetPlayer.items[trade.itemId - 1] = {
         type: '素材', // TODO 食材にもなりうる
         name: `合成品(${item.name}+${item2.name})`,
         special: item.special || item2.special,
      };
      targetPlayer.items[trade.itemId2 - 1] = null;
      return {...trade,
         item: item,
         item2: item2,
      };
   }

   craft(trade) {
      const targetPlayer = this.state[trade.targetEno];
      if (!targetPlayer) {
         return {...trade,
            // warning: '対象外のプレイヤーに対する作製',
         }
      }
      const item = targetPlayer.items[trade.itemId - 1];
      if (!item) {
         return {...trade,
            warning: '存在しないアイテムで作製',
         }
      }
      if (item.type !== '素材') {
         return {...trade,
            item: item,
            warning: '素材でないアイテムで作製',
         };
      }
      targetPlayer.items[trade.itemId - 1] = {
         type: trade.itemType,
         name: `${trade.itemType}(${item.name})`,
         special: item.special,
      };
      return {...trade,
         item: item,
      };
   }

   cook(trade) {
      const targetPlayer = this.state[trade.targetEno];
      if (!targetPlayer) {
         return {...trade,
            // warning: '対象外のプレイヤーに対する料理',
         }
      }
      const item = targetPlayer.items[trade.itemId - 1];
      if (!item) {
         return {...trade,
            warning: '存在しないアイテムで料理',
         }
      }
      if (!isFood(item.type)) {
         return {...trade,
            item: item,
            warning: '食材でないアイテムで料理',
         };
      }
      targetPlayer.items[trade.itemId - 1] = {
         type: trade.itemType,
         name: `${trade.itemType}(${item.name})`,
         special: item.special,
      };
      return {...trade,
         item: item,
      };
   }

   enchant(trade) {
      const targetPlayer = this.state[trade.targetEno];
      if (!targetPlayer) {
         return {...trade,
            // warning: '対象外のプレイヤーに対する付加',
         }
      }
      const item = targetPlayer.items[trade.itemId - 1];
      const item2 = targetPlayer.items[trade.itemId2 - 1];
      if (!item) {
         return {...trade,
            item: item,
            item2: item2,
            warning: '存在しないアイテムに付加',
         }
      }
      if (!isEquipment(item.type)) {
         return {...trade,
            item: item,
            item2: item2,
            warning: '装備でないアイテムに付加',
         };
      }
      if (!item2) {
         return {...trade,
            item: item,
            item2: item2,
            warning: '存在しないアイテムを付加',
         }
      }
      if (!isMaterial(item2.type)) {
         return {...trade,
            item: item,
            item2: item2,
            warning: '素材でないアイテムを付加',
         };
      }
      targetPlayer.items[trade.itemId - 1] = {
         type: item.type,
         name: `${item.name}+付加(${item2.name})`,
         special: item.special,
      };
      targetPlayer.items[trade.itemId2 - 1] = null;
      return {...trade,
         item: item,
         item2: item2,
      };
   }

   apply(trade) {
      switch (trade.type) {
         case 'アイテム破棄':
            return this.trashItem(trade);
         case 'アイテム手渡し':
         case 'アイテム送付':
            return this.sendItem(trade);
         case 'アイテム手渡し(外部から)':
         case 'アイテム送付(外部から)':
            return this.sendItemFromOutside(trade);
         case '食事':
            return this.eatItem(trade);
         case 'PS送付':
            return this.sendPs(trade);
         case 'アイテム購入':
            return this.buyItem(trade);
         case '合成':
            return this.synthesize(trade);
         case '作製':
            return this.craft(trade);
         case '料理':
            return this.cook(trade);
         case '付加':
            return this.enchant(trade);
      }
      return trade;
   }

   players() {
      const ret = Object.values(this.state);
      ret.sort((a, b) => a.eno - b.eno);
      return ret;
   }
}
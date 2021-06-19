// アイテムデータはこちらを利用しています。 https://docs.google.com/spreadsheets/d/1k8GHMcF4DUg_FdBr7mIdBmLEAw-EdOOKD6th7Im4frY

import { players } from './fixtures/players_31';
const itemData = require('./fixtures/items.csv');

export { players, itemData };

export function material_strength(itemName) {
   const item = itemData.find(row => row['アイテム名'] === itemName)
   if (item) {
      return item['可能強度範囲']
   } else {
      return null;
   }
}

export const shopItems = [
   { name: 'エナジー棒', type: '料理', price: 30, special: false, power: 10, effect1: { name: '活力', lv: 10 }, effect2: { name: '防御', lv: 10 } },
   { name: '駄木', type: '素材', price: 50, special: false, power: 10, effect1: { name: '攻撃', lv: 10, reqlv: 20 }, effect2: { name: '敏捷', lv: 10, reqlv: 20 }, effect3: { name: '回復', lv: 10, reqlv: 20 } },
   { name: '良い木材', type: '素材', price: 200, special: false, power: 20, effect1: { name: '攻撃', lv: 15, reqlv: 30 }, effect2: { name: '敏捷', lv: 15, reqlv: 30 }, effect3: { name: '回復', lv: 15, reqlv: 30 } },
   { name: 'すごい木材', type: '素材', price: 400, special: false, power: 30, effect1: { name: '攻撃', lv: 20, reqlv: 40 }, effect2: { name: '敏捷', lv: 20, reqlv: 40 }, effect3: { name: '回復', lv: 20, reqlv: 40 } },
   { name: '駄石', type: '素材', price: 50, special: false, power: 10, effect1: { name: '体力', lv: 10, reqlv: 20 }, effect2: { name: '防御', lv: 10, reqlv: 20 }, effect3: { name: '幸運', lv: 10, reqlv: 20 } },
   { name: '良い石材', type: '素材', price: 200, special: false, power: 20, effect1: { name: '体力', lv: 15, reqlv: 30 }, effect2: { name: '防御', lv: 15, reqlv: 30 }, effect3: { name: '幸運', lv: 15, reqlv: 30 } },
   { name: 'すごい石材', type: '素材', price: 400, special: false, power: 30, effect1: { name: '体力', lv: 20, reqlv: 40 }, effect2: { name: '防御', lv: 20, reqlv: 40 }, effect3: { name: '幸運', lv: 20, reqlv: 40 } },
   { name: 'お肉', type: '食材', price: 50, special: false, power: 10, effect1: { name: '攻撃', lv: 10, reqlv: 15 }, effect2: { name: '防御', lv: 10, reqlv: 25 }, effect3: { name: '増幅', lv: 10, reqlv: 35 } },
   { name: '良いお肉', type: '食材', price: 200, special: false, power: 20, effect1: { name: '攻撃', lv: 20, reqlv: 20 }, effect2: { name: '防御', lv: 20, reqlv: 30 }, effect3: { name: '増幅', lv: 20, reqlv: 40 } },
   { name: 'すごいお肉', type: '食材', price: 400, special: false, power: 30, effect1: { name: '攻撃', lv: 30, reqlv: 25 }, effect2: { name: '防御', lv: 30, reqlv: 35 }, effect3: { name: '増幅', lv: 30, reqlv: 45 } },
   { name: 'お魚', type: '食材', price: 50, special: false, power: 10, effect1: { name: '活力', lv: 10, reqlv: 15 }, effect2: { name: '敏捷', lv: 10, reqlv: 25 }, effect3: { name: '強靭', lv: 10, reqlv: 35 } },
   { name: '良いお魚', type: '食材', price: 200, special: false, power: 20, effect1: { name: '活力', lv: 20, reqlv: 20 }, effect2: { name: '敏捷', lv: 20, reqlv: 30 }, effect3: { name: '強靭', lv: 20, reqlv: 40 } },
   { name: 'すごいお魚', type: '食材', price: 400, special: false, power: 30, effect1: { name: '活力', lv: 30, reqlv: 25 }, effect2: { name: '敏捷', lv: 30, reqlv: 35 }, effect3: { name: '強靭', lv: 30, reqlv: 45 } },
   { name: 'お野菜', type: '食材', price: 50, special: false, power: 10, effect1: { name: '器用', lv: 10, reqlv: 15 }, effect2: { name: '幸運', lv: 10, reqlv: 25 }, effect3: { name: '命脈', lv: 10, reqlv: 35 } },
   { name: '良いお野菜', type: '食材', price: 200, special: false, power: 20, effect1: { name: '器用', lv: 20, reqlv: 20 }, effect2: { name: '幸運', lv: 20, reqlv: 30 }, effect3: { name: '命脈', lv: 20, reqlv: 40 } },
   { name: 'すごいお野菜', type: '食材', price: 400, special: false, power: 30, effect1: { name: '器用', lv: 30, reqlv: 25 }, effect2: { name: '幸運', lv: 30, reqlv: 35 }, effect3: { name: '命脈', lv: 30, reqlv: 45 } },
   { name: '生命の宝石', type: '素材', price: 800, special: false, power: 30, effect1: { name: '快癒', lv: 30, reqlv: 70}, effect2: { name: '活力', lv: 30, reqlv: 70}, effect3: { name: '耐疫', lv: 30, reqlv: 70} },
   { name: '精神の宝石', type: '素材', price: 800, special: false, power: 30, effect1: { name: '魔力', lv: 30, reqlv: 70}, effect2: { name: '気合', lv: 30, reqlv: 70}, effect3: { name: '耐狂', lv: 30, reqlv: 70} },
   { name: '乱流の宝石', type: '素材', price: 800, special: false, power: 30, effect1: { name: '連撃', lv: 30, reqlv: 70}, effect2: { name: '反撃', lv: 30, reqlv: 70}, effect3: { name: '耐災', lv: 30, reqlv: 70} },
   { name: '朝凪の宝石', type: '素材', price: 800, special: false, power: 30, effect1: { name: '共鳴', lv: 30, reqlv: 70}, effect2: { name: '回復', lv: 30, reqlv: 70}, effect3: { name: '反射', lv: 30, reqlv: 70} },
   { name: '夕凪の宝石', type: '素材', price: 800, special: false, power: 30, effect1: { name: '心酔', lv: 30, reqlv: 70}, effect2: { name: '舞祝', lv: 30, reqlv: 70}, effect3: { name: '充填', lv: 30, reqlv: 70} },
   { name: '赤色の果実', type: '食材', price: 800, special: false, power: 40, effect1: { name: '器用', lv: 30, reqlv: 40}, effect2: { name: '幸運', lv: 35, reqlv: 60}, effect3: { name: '連撃', lv: 40, reqlv: 80} },
   { name: '橙色の果実', type: '食材', price: 800, special: false, power: 40, effect1: { name: '迫撃', lv: 30, reqlv: 40}, effect2: { name: '閃撃', lv: 35, reqlv: 60}, effect3: { name: '深手', lv: 40, reqlv: 80} },
   { name: '黄色い果実', type: '食材', price: 800, special: false, power: 40, effect1: { name: '壊裂', lv: 30, reqlv: 40}, effect2: { name: '増勢', lv: 35, reqlv: 60}, effect3: { name: '舞反', lv: 40, reqlv: 80} },
   { name: '緑色の果実', type: '食材', price: 800, special: false, power: 40, effect1: { name: '敏捷', lv: 30, reqlv: 40}, effect2: { name: '快癒', lv: 35, reqlv: 60}, effect3: { name: '風柳', lv: 40, reqlv: 80} },
   { name: '青色の果実', type: '食材', price: 800, special: false, power: 40, effect1: { name: '気合', lv: 30, reqlv: 40}, effect2: { name: '魔脈', lv: 35, reqlv: 60}, effect3: { name: '魔力', lv: 40, reqlv: 80} },
   { name: '紫色の果実', type: '食材', price: 800, special: false, power: 40, effect1: { name: '強靭', lv: 30, reqlv: 40}, effect2: { name: '反護', lv: 35, reqlv: 60}, effect3: { name: '防御', lv: 40, reqlv: 80} },
   { name: 'ものすごい木材', type: '素材', price: 1500, special: false, power: 40, effect1: { name: '攻撃', lv: 40, reqlv: 80 }, effect2: { name: '敏捷', lv: 40, reqlv: 80 }, effect3: { name: '回復', lv: 40, reqlv: 80 } },
   { name: 'ものすごい石材', type: '素材', price: 1500, special: false, power: 40, effect1: { name: '体力', lv: 40, reqlv: 80 }, effect2: { name: '防御', lv: 40, reqlv: 80 }, effect3: { name: '幸運', lv: 40, reqlv: 80 } },
   { name: 'ものすごいお肉', type: '食材', price: 1500, special: false, power: 40, effect1: { name: '攻撃', lv: 40, reqlv: 50 }, effect2: { name: '防御', lv: 40, reqlv: 70 }, effect3: { name: '増幅', lv: 40, reqlv: 90 } },
   { name: 'ものすごいお魚', type: '食材', price: 1500, special: false, power: 40, effect1: { name: '活力', lv: 40, reqlv: 50 }, effect2: { name: '敏捷', lv: 40, reqlv: 70 }, effect3: { name: '強靭', lv: 40, reqlv: 90 } },
   { name: 'ものすごいお野菜', type: '食材', price: 1500, special: false, power: 40, effect1: { name: '器用', lv: 40, reqlv: 50 }, effect2: { name: '幸運', lv: 40, reqlv: 70 }, effect3: { name: '命脈', lv: 40, reqlv: 90 } },
];
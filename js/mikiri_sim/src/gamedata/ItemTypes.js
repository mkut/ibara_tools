const itemTypes = ['素材', '食材', '武器', '大砲', '呪器', '防具', '法衣', '装飾', '魔晶', '料理'];
const equipmentTypes = ['武器', '大砲', '呪器', '防具', '法衣', '装飾', '魔晶'];

function isMaterial(itemType) {
   return itemType === '素材';
}
function isFood(itemType) {
   return itemType === '食材';
}
function isWeapon(itemType) {
   return ['武器', '大砲', '呪器'].includes(itemType);
}
function isArmor(itemType) {
   return ['防具', '法衣'].includes(itemType);
}
function isAccessory(itemType) {
   return ['装飾', '魔晶'].includes(itemType);
}
function isDish(itemType) {
   return itemType === '料理';
}
function isEquipment(itemType) {
   return isWeapon(itemType) || isArmor(itemType) || isAccessory(itemType);
}

export { itemTypes, equipmentTypes, isMaterial, isFood, isWeapon, isArmor, isAccessory, isDish, isEquipment };
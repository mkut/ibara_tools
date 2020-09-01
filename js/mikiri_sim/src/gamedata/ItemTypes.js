const weaponTypes = ['武器', '大砲', '呪器', '魔弾', '戦盾'];
const armorTypes = ['防具', '法衣', '重鎧', '衣装', '隔壁'];
const accessoryTypes = ['装飾', '魔晶', '護符', '御守', '薬箱'];
const dishTypes = ['料理', '魔香', '賄飯'];

const equipmentTypes = [
   ...weaponTypes,
   ...armorTypes,
   ...accessoryTypes,
];

const itemTypes = [
   '素材', '食材',
   ...equipmentTypes,
   ...dishTypes,
];

function isMaterial(itemType) {
   return itemType === '素材';
}
function isFood(itemType) {
   return itemType === '食材';
}
function isWeapon(itemType) {
   return weaponTypes.includes(itemType);
}
function isArmor(itemType) {
   return armorTypes.includes(itemType);
}
function isAccessory(itemType) {
   return accessoryTypes.includes(itemType);
}
function isDish(itemType) {
   return dishTypes.includes(itemType);
}
function isEquipment(itemType) {
   return isWeapon(itemType) || isArmor(itemType) || isAccessory(itemType);
}

export { itemTypes, equipmentTypes, dishTypes, isMaterial, isFood, isWeapon, isArmor, isAccessory, isDish, isEquipment };
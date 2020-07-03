export function formatDate(date) {
   let ret = '';
   ret += date.getFullYear();
   ret += ('0' + (date.getMonth() + 1)).slice(-2);
   ret += ('0' + date.getDate()).slice(-2);
   ret += ('0' + date.getHours()).slice(-2);
   ret += ('0' + date.getMinutes()).slice(-2);
   ret += ('0' + date.getSeconds()).slice(-2);
   ret += ('00' + date.getMilliseconds()).slice(-3);
   return ret;
 };
import firebase from 'firebase/app';
import 'firebase/firestore'

let db = null;
switch (location.host) {
   case 'mkut.github.io':
      firebase.initializeApp({
         apiKey: "AIzaSyBzthSJ3s8l8e9N2xXKbSIP6AbVspsn_Q0",
         authDomain: "ibara-tools-mikiri-sim.firebaseapp.com",
         databaseURL: "https://ibara-tools-mikiri-sim.firebaseio.com",
         projectId: "ibara-tools-mikiri-sim",
         storageBucket: "ibara-tools-mikiri-sim.appspot.com",
         messagingSenderId: "614554001061",
         appId: "1:614554001061:web:9b423819fe64b1308b774c"
      });
      db = firebase.firestore();
      break;
   default:
}

export {db};
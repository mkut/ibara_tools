import React from 'react'
import Location from './Location';

export default class Locations extends React.Component {
   render() {
      return (
         <table className="locations-table">
            <thead>
               <tr>
                  <th>ENO</th>
                  <th>プレイヤー名</th>
                  <th>ItemNo</th>
                  <th>特殊アイテム</th>
               </tr>
            </thead>
            <tbody>
               {this.props.locations.map((location, i) => <Location key={i} location={location} />)}
            </tbody>
         </table>
      )
   }
}
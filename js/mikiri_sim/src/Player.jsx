import React from 'react'
import Item from './Item'

export default class Player extends React.Component {
   render () {
      const { eno, name, ps, items } = this.props.player;
      return (
         <div className="player">
            <table>
               <tbody>
                  <tr>
                     <th>ENO</th>
                     <td>{eno}</td>
                  </tr>
                  <tr>
                     <th>名前</th>
                     <td>{name}</td>
                  </tr>
                  <tr>
                     <th>PS</th>
                     <td>{ps}</td>
                  </tr>
                  {items.map((item, i) => <tr key={i}>
                     <th>#{i+1}</th>
                     <td><Item item={item} /></td>
                  </tr>)}
               </tbody>
            </table>
         </div>
      );
   }
}
import React from 'react'
import 'react-tabs/style/react-tabs.css';

export default class Researches extends React.Component {
   render() {
      let skills = new Set();
      this.props.players.forEach(player => {
         Object.keys(player.researches).forEach(skill => {
            skills.add(skill);
         })
      });
      skills = [...skills];
      const players = this.props.teams.map(team => team.map(eno => this.props.players.find(p => p.eno === eno)));
      return (
         <table className="research-table">
            <thead>
               <tr>
                  <td />
                  {players.map((team, i) => <th key={i} colSpan={team.length+1}>Team#{i+1}</th>)}
               </tr>
               <tr>
                  <td>スキル名</td>
                  {players.map((team, i) => team.flatMap(player => <th key={player.eno}>{player.name.substring(0, 3)}</th>).concat(<th key={`total${i}`}>合計</th>))}
               </tr>
            </thead>
            <tbody>
               {skills.map(skill => <tr>
                  <td>{skill}</td>
                  {players.flatMap(team => team.map(player => <td key={player.eno}>
                     {player.researches[skill]}
                  </td>).concat(<td>{team.map(player => player.researches[skill] || 0).reduce((x, y) => x + y)}</td>))}
               </tr>)}
            </tbody>
         </table>
      )
   }
}
import React from 'react'

export default class Material extends React.Component {
   render() {
      if (!this.props.effect) {
         return <span>─</span>
      }
      return (
         <span>
            {this.props.effect.name}
            {this.props.effect.lv}
            {this.props.effect.reqlv && <span className="reqlv">(LV{this.props.effect.reqlv})</span>}
         </span>
      );
   }
}
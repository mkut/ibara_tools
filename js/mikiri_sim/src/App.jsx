import React from 'react'
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';
import 'react-tabs/style/react-tabs.css';
import Players from './players/Players'
import Materials from './materials/Materials';
import Trades from './trades/Trades'
import { players } from './fixtures';
import Equipments from './equipment/Equipments';

export default class App extends React.Component {
   constructor(...args) {
      super(...args);
      this.state = {
         players: players,
         finalState: players,
      };
   }

   handleChangeFinalState(newValue) {
      this.setState({
         finalState: newValue,
      });
   }

   render() {
      return <div>
         <Tabs>
            <TabList>
               <Tab>取引管理</Tab>
               <Tab>素材一覧</Tab>
               <Tab>食材一覧</Tab>
               <Tab>装備一覧</Tab>
               <Tab>初期状態(旧)</Tab>
               <Tab>最終状態(旧)</Tab>
            </TabList>
            <TabPanel>
               <Trades players={this.state.players} onChangeFinalState={this.handleChangeFinalState.bind(this)} />
            </TabPanel>
            <TabPanel>
               <Materials players={this.state.players} itemType="素材" />
            </TabPanel>
            <TabPanel>
               <Materials players={this.state.players} itemType="食材" />
            </TabPanel>
            <TabPanel>
               <Equipments players={this.state.players} />
            </TabPanel>
            <TabPanel>
               <Players players={this.state.players} />
            </TabPanel>
            <TabPanel>
               <Players players={this.state.finalState} />
            </TabPanel>
         </Tabs>
      </div>
   }

}
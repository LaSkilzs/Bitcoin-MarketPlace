import React from "react";
import SideNav from "../component/SideNav";
import MainGrid from "../component/MainGrid";

class Dashboard extends React.Component {
  render() {
    return (
      <React.Fragment>
        <SideNav />
        <MainGrid />
      </React.Fragment>
    );
  }
}
export default Dashboard;

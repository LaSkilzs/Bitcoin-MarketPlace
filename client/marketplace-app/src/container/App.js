import React from "react";
import "./css/App.css";
import Navbar from "../component/Navbar";
import Dashboard from "./Dashboard";

function App() {
  return (
    <React.Fragment>
      <Navbar />
      <Dashboard />
    </React.Fragment>
  );
}

export default App;

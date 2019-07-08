import React from "react";
import "./css/App.css";
import Navbar from "../component/Navbar";
import Dashboard from "./Dashboard";

function App() {
  return (
    <div className="app">
      <Navbar />
      <Dashboard />
    </div>
  );
}

export default App;

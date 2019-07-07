import React from "react";
import "./css/App.css";
import Navbar from "../component/Navbar";
import Drawer from "../component/Drawer";

function App() {
  return (
    <div className="App">
      <Navbar />
      <Drawer />
    </div>
  );
}

export default App;

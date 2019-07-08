import React from "react";
import { Drawer, makeStyles } from "@material-ui/core";
import List from "./SimpleList";

const sideLinks = [
  ["Home", "home"],
  ["Exchange", "store"],
  ["Wallet", "account_balance_wallet"],
  ["Trading", "euro_symbol"]
];

const drawerWidth = 240;

const useStyles = makeStyles(theme => ({
  drawer: {
    width: drawerWidth
  }
}));

const SideNav = () => {
  const classes = useStyles();

  return (
    <div>
      <Drawer variant="permanent" className={classes.drawer}>
        <List items={sideLinks} />
      </Drawer>
    </div>
  );
};

export default SideNav;

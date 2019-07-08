import React from "react";
import { Drawer, makeStyles } from "@material-ui/core";
import List from "./SimpleList";

const sideLinks = [
  ["Home", "home"],
  ["Exchange", "store"],
  ["Wallet", "account_balance_wallet"],
  ["Withdraw", "card_giftcard"],
  ["Deposit", "payment"],
  ["Trading", "euro_symbol"],
  ["News", "web"],
  ["Watchlist", "format_list_numbered"],
  ["Portfolio", "work"]
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

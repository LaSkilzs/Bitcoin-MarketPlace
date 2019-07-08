import React from "react";
import { AppBar, makeStyles, Typography } from "@material-ui/core";

const drawerWidth = 160;

const useStyles = makeStyles(theme => ({
  navbar: {
    background: "red",
    position: "fixed",
    width: `calc(100% - ${drawerWidth}px)`
  },
  title: {
    display: "flex",
    fontSize: "1.3rem"
  },
  header: {
    display: "flex",
    justifyContent: "space between",
    padding: "0.5rem"
  },
  icons: {
    marginLeft: "auto"
  },
  iconRoot: {
    padding: "5px",
    fontSize: "1rem"
  }
}));

const Navbar = () => {
  let classes = useStyles();
  return (
    <div>
      <AppBar className={classes.navbar}>
        <div className={classes.header}>
          <Typography className={classes.title}>Marketplace</Typography>
          <div className={classes.icons}>
            <i className="material-icons">email</i>
            <i className="material-icons">notification_important</i>
            <i className="material-icons">account_circle</i>
          </div>
        </div>
      </AppBar>
    </div>
  );
};
export default Navbar;

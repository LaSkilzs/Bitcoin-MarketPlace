import React from "react";
import { AppBar, makeStyles, Typography, SvgIcon} from "@material-ui/core";




const useStyles = makeStyles(theme => ({
  navbar: {
    background: "red",
    position: "fixed",
    padding: "1.5rem"
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
      <AppBar className={classes.navbar}>
        <div className={classes.header}>
        <Typography className={classes.title}>Marketplace</Typography>
        <div className={classes.icons}>
          <SvgIcon >
            <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
          </SvgIcon>
          <SvgIcon>
            <path d="M10.01 21.01c0 1.1.89 1.99 1.99 1.99s1.99-.89 1.99-1.99h-3.98zm8.87-4.19V11c0-3.25-2.25-5.97-5.29-6.69v-.72C13.59 2.71 12.88 2 12 2s-1.59.71-1.59 1.59v.72C7.37 5.03 5.12 7.75 5.12 11v5.82L3 18.94V20h18v-1.06l-2.12-2.12zM16 13.01h-3v3h-2v-3H8V11h3V8h2v3h3v2.01z"/>
          </SvgIcon>
          <SvgIcon>
            <path d="M12 5.9c1.16 0 2.1.94 2.1 2.1s-.94 2.1-2.1 2.1S9.9 9.16 9.9 8s.94-2.1 2.1-2.1m0 9c2.97 0 6.1 1.46 6.1 2.1v1.1H5.9V17c0-.64 3.13-2.1 6.1-2.1M12 4C9.79 4 8 5.79 8 8s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4zm0 9c-2.67 0-8 1.34-8 4v3h16v-3c0-2.66-5.33-4-8-4z"/>
          </SvgIcon>
          </div>
        </div> 

      </AppBar>
  );
};
export default Navbar;



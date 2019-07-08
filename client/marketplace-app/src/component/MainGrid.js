import React from "react";
import { makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import Divider from "@material-ui/core/Divider";
import Grid from "@material-ui/core/Grid";

const useStyles = makeStyles(theme => ({
  grid: {
    marginTop: 100,
    marginLeft: 200,
    width: "80rem"
  },
  subGrid: {
    marginTop: 60,
    marginLeft: 200,
    width: "80rem"
  }
}));

const MainGrid = () => {
  const classes = useStyles();
  return (
    <React.Fragment>
      <Grid container spacing={3} className={classes.grid}>
        <Grid item xs={3}>
          <Paper style={{ height: "10vh" }}>Account Balance</Paper>
        </Grid>
        <Grid item xs={3}>
          <Paper style={{ height: "10vh" }}>Last Day Revenue</Paper>
        </Grid>
        <Grid item xs={3}>
          <Paper style={{ height: "10vh" }}>Revenue this Month</Paper>
        </Grid>
        <Grid item xs={3}>
          <Paper style={{ height: "10vh" }}>Revenue this year</Paper>
        </Grid>
        <Grid item xs={9}>
          <Paper style={{ height: "50vh" }}>Zap Chart</Paper>
        </Grid>
        <Grid item xs={3}>
          <Paper style={{ height: "50vh" }}>Profile Card</Paper>
        </Grid>
      </Grid>
      <div>
        <Grid container spacing={3} className={classes.subGrid}>
          <Grid item xs={6}>
            <Paper style={{ height: "10vh" }}>Recent Activity</Paper>
          </Grid>
          <Grid item xs={6}>
            <Paper style={{ height: "10vh" }}>Top Trades</Paper>
          </Grid>
        </Grid>
      </div>
    </React.Fragment>
  );
};

export default MainGrid;

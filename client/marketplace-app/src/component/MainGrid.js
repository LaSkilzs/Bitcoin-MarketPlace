import React from "react";
import { makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import Divider from "@material-ui/core/Divider";
import Grid from "@material-ui/core/Grid";

const MainGrid = () => {
  return (
    <React.Fragment>
      <Grid container spacing={3}>
        <Grid item xs={3}>
          <Paper>small dash 1</Paper>
        </Grid>
        <Grid item xs={3}>
          <Paper>small dash 2</Paper>
        </Grid>
        <Grid item xs={3}>
          <Paper>small dash 3</Paper>
        </Grid>
        <Grid item xs={8}>
          <Paper>main dash 1</Paper>
        </Grid>
        <Grid item xs={4}>
          <Paper>medium dash 1</Paper>
        </Grid>
      </Grid>
      <Divider />
      <Grid container spacing={3}>
        <Grid item xs={3}>
          <Paper>small dash 4</Paper>
        </Grid>
        <Grid item xs={3}>
          <Paper>small dash 5</Paper>
        </Grid>
        <Grid item xs={3}>
          <Paper>small dash 6</Paper>
        </Grid>
      </Grid>
    </React.Fragment>
  );
};

export default MainGrid;

import React from "react";
import List from "@material-ui/core/List";
import ListItem from "@material-ui/core/ListItem";
import ListItemText from "@material-ui/core/ListItemText";
import ListItemIcon from "@material-ui/core/ListItemIcon";
import Divider from "@material-ui/core/Divider";

const SimpleList = props => {
  return (
    <List>
      <ListItemText style={{ marginTop: 80 }}>
        {/* <i
          className="fab fa-bitcoin"
          style={{ fontSize: 75, color: "#8e6d19" }}
        /> */}
      </ListItemText>
      <Divider />
      {props.items.map((link, index) => {
        return (
          <ListItem key={index}>
            <ListItemIcon>
              <i className="material-icons">{link[1]}</i>
            </ListItemIcon>
            <ListItemText primary={link[0]} />
          </ListItem>
        );
      })}
    </List>
  );
};

export default SimpleList;

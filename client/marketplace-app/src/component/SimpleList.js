import React from "react";
import List from "@material-ui/core/List";
import ListItem from "@material-ui/core/ListItem";
import ListItemText from "@material-ui/core/ListItemText";
import ListItemIcon from "@material-ui/core/ListItemIcon";

const SimpleList = props => {
  return (
    <List>
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

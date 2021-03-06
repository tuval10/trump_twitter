import React from 'react';
import {ListItemIcon, ListItemText, ListItem} from '@material-ui/core';
import {Home, MenuBook, Update, Timeline} from '@material-ui/icons';
import Link from 'next/link'

export const mainListItems = (
  <div>
    <Link href="/" as="/">
      <ListItem button>
        <ListItemIcon>
          <Home/>
        </ListItemIcon>
        <ListItemText primary="Home"/>
      </ListItem>
    </Link>
    <Link href="/tweets_retweets/[group_by]" as="/tweets_retweets/Day">
      <ListItem button>
        <ListItemIcon>
          <Timeline/>
        </ListItemIcon>
        <ListItemText primary="Tweets vs. Retweets"/>
      </ListItem>
    </Link>
    <Link href="/words/[group_by]" as="/words/Day">
      <ListItem button>
        <ListItemIcon>
          <MenuBook/>
        </ListItemIcon>
        <ListItemText primary="Links word count"/>
      </ListItem>
    </Link>
    <Link href="/tweeting_time/[group_by]" as="/tweeting_time/1">
      <ListItem button>
        <ListItemIcon>
          <Update/>
        </ListItemIcon>
        <ListItemText primary="Tweeting time of day"/>
      </ListItem>
    </Link>
  </div>
);
import React from 'react';
import PropTypes from 'prop-types';
import Link from 'next/link'
import {Button, Grid, Container, Typography} from '@material-ui/core';
import {groupByDateValues, groupByMinuteValues} from "../helpers/timeHelper";
import {makeStyles} from '@material-ui/core/styles';

const possibleGroupByValues = [
  ...groupByDateValues,
  ...groupByMinuteValues
];

const useStyles = makeStyles((theme) => ({
  subtitle: {
    fontWeight: 'bold',
  }
}));

const toButtons = ({values, baseUrl, selected}, buttonWidth) => {
  return values.map(value => {
    return (
      <Grid item xs={buttonWidth} md={buttonWidth} lg={buttonWidth} key={value}>
        <Link href={`${baseUrl}/[group_by]`} as={`${baseUrl}/${value}`}>
          <Button variant="contained" fullWidth={true}
                  color={value === selected ? "primary" : "default"}>
            {value}
          </Button>
        </Link>
      </Grid>
    )
  })
}

export default function GroupingSelector(props) {
  const classes = useStyles();
  const childWidth = Math.floor(12.0 / (props.values.length + 1));
  return (
    <Container maxWidth="lg">
      <Grid container spacing={3} justify="center" alignItems="center">
        <Grid item xs={childWidth} md={childWidth} lg={childWidth} >
          <Typography variant="subtitle1" className={classes.subtitle}>
                      {props.text}
          </Typography>
        </Grid>
        {toButtons(props, childWidth)}
      </Grid>
    </Container>
  )
};


GroupingSelector.propTypes = {
  values: PropTypes.arrayOf(PropTypes.oneOf(possibleGroupByValues)),
  baseUrl: PropTypes.string,
  selected: PropTypes.oneOf(possibleGroupByValues),
  text: PropTypes.string
};
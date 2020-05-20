import React from 'react';
import Layout from '../layout/Layout';
import Link from 'next/link'
import {
  Paper,
  Button,
  Container,
  Grid,
  Typography,
  Divider
} from '@material-ui/core';

export default function Index() {
  return (
    <Layout title="Welcome to Trump's Twitter statistic" wrapper={false}>
      <Container maxWidth="lg">
        <Grid container spacing={3}>
          <Grid item xs={12} md={8} lg={9}>
            <Typography variant="h2" component="h7">
              Take a look at those graphs!
            </Typography>
          </Grid>
        </Grid>
      </Container>
      <Divider/>
      <Container maxWidth="lg">
        <Grid container spacing={3}>
          <Grid item xs={12} md={8} lg={9}>
            <Link href="/tweeting_time/[group_by]" as="/tweeting_time/1">
              <Button variant="contained" color="primary">
                <a>Tweets by time of day</a>
              </Button>
            </Link>
          </Grid>
        </Grid>
      </Container>
      <Container maxWidth="lg">
        <Grid container spacing={3}>
          <Grid item xs={12} md={8} lg={9}>
            <Link href="/tweets_retweets/[group_by]" as="/tweets_retweets/Day">
              <Button variant="contained" color="primary">
                <a>Number of tweets vs. Number of retweets</a>
              </Button>
            </Link>
          </Grid>
        </Grid>
      </Container>
      <Container maxWidth="lg">
        <Grid container spacing={3}>
          <Grid item xs={12} md={8} lg={9}>
            <Link href="/words/[group_by]" as="/words/Day">
              <Button variant="contained" color="primary">
                <a>Selected words occurrences</a>
              </Button>
            </Link>
          </Grid>
        </Grid>
      </Container>
    </Layout>
  );
}

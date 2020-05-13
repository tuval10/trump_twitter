import React from 'react';
import Layout from '../layout/Layout';
import TweetsTimeOfDayChart from '../components/TweetsTimeOfDayChart';
import {getTweetsByMinueReport} from '../helpers/backendApi'

export const getServerSideProps = async ({query}) => {
  const data = await getTweetsByMinueReport();
  return {props: {data}};
};

export default function TweetHour({data}) {
  return (
    <Layout title="Tweet hour">
      <TweetsTimeOfDayChart data={data}/>
    </Layout>
  );
}

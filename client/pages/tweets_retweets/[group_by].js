import React from "react";
import TweetsVsRetweetsChart from '../../components/TweetsVsRetweetsChart';
import Layout from '../../layout/Layout';
import {getTweetsDailyReport} from '../../helpers/backendApi'

export const getServerSideProps = async ({ query }) => {
  const data = await getTweetsDailyReport();
  return { props: {data, group_by: query.group_by} };
};

export default class TweetsRetweets extends React.Component {
  render() {
    return (
      <Layout title="Tweet versus Retweet">
        <TweetsVsRetweetsChart data={this.props.data}/>
      </Layout>
    );
  }
}
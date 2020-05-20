import React from "react";
import TweetsVsRetweetsChart from '../../components/TweetsVsRetweetsChart';
import Layout from '../../layout/Layout';
import {getTweetsDailyReport} from '../../helpers/backendApi'
import {groupByPeriod, groupByDateValues, getGroupByPeriodParam} from '../../helpers/timeHelper'
import GroupingSelector from "../../components/GroupingSelector";


export const getServerSideProps = async ({query}) => {
  let data = await getTweetsDailyReport();
  let groupBy = getGroupByPeriodParam(query);
  if (groupBy != 'Day')
    data = groupByPeriod(query.group_by, data, ['tweets', 'retweets']);
  return {props: {data, groupBy}};
};

export default class TweetsRetweets extends React.Component {
  render() {
    return (
      <Layout title="Tweet versus Retweet">
        <GroupingSelector text={"Group by:"} values={groupByDateValues} selected={this.props.groupBy} baseUrl="/tweets_retweets" />
        <TweetsVsRetweetsChart data={this.props.data}/>
      </Layout>
    );
  }
}
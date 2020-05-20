import React from 'react';
import Layout from '../../layout/Layout';
import TweetsTimeOfDayChart from '../../components/TweetsTimeOfDayChart';
import {getTweetsByMinueReport} from '../../helpers/backendApi'
import {groupByPeriod, getGroupByMinuteParam, groupByMinuteValues} from '../../helpers/timeHelper'
import GroupingSelector from "../../components/GroupingSelector";

export const getServerSideProps = async ({query}) => {
  let data = await getTweetsByMinueReport();
  let groupBy = getGroupByMinuteParam(query);
  if (groupBy !== 1)
    data = groupByPeriod(query.group_by, data, ['tweets']);
  return {props: {data, groupBy: groupBy.toString()}};
};

export default function TweetHour({data, groupBy}) {
  return (
    <Layout title="Tweet hour">
      <GroupingSelector text={"Group by (minute):"} values={groupByMinuteValues} selected={groupBy} baseUrl="/tweeting_time" />
      <TweetsTimeOfDayChart data={data}/>
    </Layout>
  );
}

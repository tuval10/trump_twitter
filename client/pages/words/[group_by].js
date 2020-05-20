import React from "react";
import Layout from '../../layout/Layout';
import WordsCountChart from '../../components/WordsCountChart';
import {getWordsDailyReport} from '../../helpers/backendApi'
import {groupByPeriod, groupByDateValues, getGroupByPeriodParam} from '../../helpers/timeHelper'
import GroupingSelector from "../../components/GroupingSelector";

const keys = (process.env.NEXT_PUBLIC_KEYWORDS || '').split(',');

export const getServerSideProps = async ({query}) => {
  let data = await getWordsDailyReport();
  let groupBy = getGroupByPeriodParam(query);
  if (groupBy != 'Day')
    data = groupByPeriod(query.group_by, data, keys);
  return {props: {data, groupBy}};
};

export default class Words extends React.Component {
  // this page fetch async stuff before rendering
  render() {
    return (
      <Layout title="Words Count">
        <GroupingSelector text={"Group by:"} values={groupByDateValues} selected={this.props.groupBy} baseUrl="/words" />
        <WordsCountChart data={this.props.data}/>
      </Layout>
    );
  }
}
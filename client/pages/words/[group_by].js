import React from "react";
import Layout from '../../layout/Layout';
import WordsCountChart from '../../components/WordsCountChart';
import {getWordsDailyReport} from '../../helpers/backendApi'

export const getServerSideProps = async ({query}) => {
  const data = await getWordsDailyReport();
  return {props: {data, group_by: query.group_by}};
};

export default class Words extends React.Component {
  // this page fetch async stuff before rendering
  render() {
    return (
      <Layout title="Words Count">
        <WordsCountChart data={this.props.data}/>
      </Layout>
    );
  }
}
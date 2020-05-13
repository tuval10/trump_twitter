import React from "react";
import Layout from '../../layout/Layout';
import WordsCountChart from '../../components/WordsCountChart';

// fake async fetch
const fakePromise = data =>
  new Promise((resolve, reject) => setTimeout(() => resolve(data), 100));

export default class Words extends React.Component {
  // this page fetch async stuff before rendering
  static async getInitialProps({query}) {
    const data = await fakePromise({
      slug: [query.group_by, query.start, query.end]
    });
    return {data};
  }

  render() {
    return (
      <Layout title="Words Count">
        <WordsCountChart/>
      </Layout>
    );
  }
}
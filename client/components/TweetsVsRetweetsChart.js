import React from 'react';
import moment from 'moment'
import PropTypes from 'prop-types'
import Highcharts from 'highcharts'
import HighchartsReact from 'highcharts-react-official'

const TweetsVsRetweetsChart = ({data}) => {
  const options = {
    title: {
      text: 'Tweets vs. Retweets'
    },
    xAxis: {
      categories: data.map(v => moment.utc(v.date, 'X').format('DD/MM/YYYY'))
    },
    series: ['tweets', 'retweets'].map(k => ({
      name: k,
      data: data.map(dateValue => dateValue[k])
    }))
  }


  return (
    <HighchartsReact
      highcharts={Highcharts}
      options={options}
    />
  );
}


TweetsVsRetweetsChart.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      date: PropTypes.number.isRequired,
      tweets: PropTypes.number.isRequired,
      retweets: PropTypes.number.isRequired,
    })
  ).isRequired
}

export default TweetsVsRetweetsChart
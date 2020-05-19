import React from 'react';
import moment from 'moment'
import PropTypes from 'prop-types'
import Highcharts from 'highcharts'
import HighchartsReact from 'highcharts-react-official'

const keys = (process.env.NEXT_PUBLIC_KEYWORDS || '').split(',');

const WordsCountChart = ({data}) => {

  const options = {
    title: {
      text: "Words appearences in links inside Trump's tweets"
    },
    xAxis: {
      categories: data.map(v => moment.utc(v.date, 'X').format('DD/MM/YYYY'))
    },
    series: keys.map(k => ({
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
};

WordsCountChart.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      date: PropTypes.number.isRequired,
      ...keys.map(k => (
        {[k]: PropTypes.number}
      ))
    })
  ).isRequired
};

export default WordsCountChart
import React from 'react';
import Highcharts from 'highcharts'
import HighchartsReact from 'highcharts-react-official'
import moment from 'moment'

export default function TweetsTimeOfDayChart({data}) {
  const categories = data.map(v => moment.utc(v.date, 'X').format('HH:mm'));
  data = data.map(dateValue => dateValue['tweets'])

  const options = {
    title: {
      text: 'Tweeting by time of day (UTC)'
    },
    xAxis: {
      categories
    },
    series: [{
      name: 'tweets',
      data
    }]
  };


  return (
    <HighchartsReact
      highcharts={Highcharts}
      options={options}
    />
  )
}
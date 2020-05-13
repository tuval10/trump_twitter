import React from 'react';
import Title from '../layout/Title';
import moment from 'moment'
import PropTypes from 'prop-types'

const data = [
  {
    time: 1503617297689, conspiracy: 4000, russia: 2400
  },
  {
    time: 1503616962277, conspiracy: 300, russia: 2300
  },
  {
    time: 1503616882654, conspiracy: 3000, russia: 2200
  },
];


const Lines = () => (
  <React.Fragment>
    {
      ['conspiracy', 'russia'].map(k =>
        <Line type="monotone" key={k} dataKey={k} stroke="#8884d8" activeDot={{r: 8}}/>
      )
    }
  </React.Fragment>
);


const WordsCountChart = () => (
  <LineChart
    width={500}
    height={300}
    data={data}
    margin={{
      top: 5, right: 30, left: 20, bottom: 5,
    }}
  >
    <XAxis
      dataKey="time"
      domain={['auto', 'auto']}
      name='Time'
      tickFormatter={(v) => moment.utc(v.date).format('DD/MM/YYYY')}
      type='number'
    />
    <YAxis/>
    <Tooltip/>
    <Legend/>
    <Lines/>
  </LineChart>
);


WordsCountChart.propTypes = {
  chartData: PropTypes.arrayOf(
    PropTypes.shape({
      time: PropTypes.number,
      value: PropTypes.number
    })
  ).isRequired
}

export default WordsCountChart
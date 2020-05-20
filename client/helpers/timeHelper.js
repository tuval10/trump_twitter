import moment from 'moment'

export const groupByDateValues = ["Day", "Week", "Month"];
export const groupByMinuteValues = ["1", "5", "15", "30", "60"];
export const getGroupByPeriodParam = ({group_by}) => groupByDateValues.includes(group_by) ? group_by : "Day";
export const getGroupByMinuteParam = ({group_by}) => groupByMinuteValues.includes(group_by) ? parseInt(group_by, 10) : 1;


const groupByDate = (data, keys) => {
  const defaults = keys.map(k => ( {[k]: 0} ));
  return data.reduce((dataGrouped, {date, ...values}) => {
    const defaultObj = Object.assign(
      {date},
      ...defaults
    );
    dataGrouped[date] = dataGrouped[date] || defaultObj;
    Object.entries(values).forEach(([k, v]) => dataGrouped[date][k] += (v || 0));
    return dataGrouped;
  }, {});
};

/* period should be Day Week Month */
const convertToStartOfDatePeriod = (period, data) => {
  return data.map(tweet => ({
    ...tweet,
    date: moment.utc(tweet["date"], 'X').startOf(period).unix()
  }));
};

/* period should be Day Week Month */
const convertToStartOfMinutePeriod = (period, data) => {
  return data.map(tweet => {
    let date = moment.utc(tweet["date"], 'X');
    const roundedDown = Math.floor(date.minute() / period) * period;
    date = date.minute(roundedDown).second(0).unix();
    return {
      ...tweet,
      date
    }
  });
};

const convertToStartOfPeriod = (period, data) => {
  const func = groupByDateValues.includes(period) ? convertToStartOfDatePeriod : convertToStartOfMinutePeriod;
  return func(period, data)
};

export const groupByPeriod = (period, data, keys) => {
  data = convertToStartOfPeriod(period, data);
  let datesGrouped = groupByDate(data, keys);
  return Object.values(datesGrouped);
};
import fetch from 'node-fetch'

const BASE_URL = `${process.env.NEXT_STATIC_API_URL}/trump_twitter_api/${process.env.NEXT_STATIC_API_VERSION}`

// fake async fetch
export const getTweetsDailyReport = async () => {
  const res = await fetch(`${BASE_URL}/tweets_daily`)
  return res.json()
};

// fake async fetch
export const getWordsDailyReport = async () => {
  const res = await fetch(`${BASE_URL}/words_daily`)
  return res.json()
};

// fake async fetch
export const getTweetsByMinueReport = async () => {
  const res = await fetch(`${BASE_URL}/tweets_by_minute`)
  return res.json()
};

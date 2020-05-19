class Reports::TweetDailyJob < ApplicationJob
  sidekiq_options queue: 'reports'

  def perform(last_updated_at)
    retweets, tweets = new_tweets(last_updated_at).partition {|v| v.is_retweet}
    tweets_by_date, retweets_by_date = tally_by_date(tweets, retweets)
    date_range(last_updated_at).each do |date|
      Reports::TweetDailyReport.create!(
        date: date.to_datetime,
        tweets: tweets_by_date[date] || 0,
        retweets: retweets_by_date[date] || 0
      )
    end
  end

  private

  def tally_by_date(*collections)
    tally_by_date = Proc.new {|collection| collection.map(&:created_at).map(&:to_date).tally}
    collections.map(&tally_by_date)
  end

  def date_range(last_updated_at)
    ((last_updated_at.to_date)..Date.today)
  end

  def new_tweets(last_updated_at)
    Tweet.where(:created_at.gte => last_updated_at.to_date.to_datetime)
  end
end

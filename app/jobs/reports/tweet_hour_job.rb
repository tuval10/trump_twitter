class Reports::TweetHourJob < ApplicationJob
  sidekiq_options queue: 'reports'

  def default_last_update
    Time.parse(ENV['DATA_SINCE'] || "2018-01-1 00:00:00 UTC")
  end

  def perform
    date_to_time_of_day = Proc.new {|time| default_last_update + (time.utc.hour).hours + (time.utc.min).minutes}
    Tweet.all.pluck(:created_at)
      .map(&date_to_time_of_day)
      .tally.map do |date, tweets|
      Reports::TweetHourReport.new(date: date, tweets: tweets).upsert
    end
  end
end

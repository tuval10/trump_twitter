require 'uri'

class Tweets::ImportJob < ApplicationJob
  def perform(*args)
    years_range.each {|year| perform_for_year(year)}
  end

  def perform_for_year(year)
    time_to_utc = Proc.new do |tweet|
      tweet[:created_at] = Time.parse(tweet[:created_at]).utc
      tweet
    end

    url = URI.parse("#{ENV['API_URL']}/#{year}.json")
    HTTParty.get(url).parsed_response
      .map(&:symbolize_keys)
      .map(&time_to_utc)
      .select {|tweet| new_tweet?(tweet)}.each do |tweet|
      Tweet.create!(
        tweet
      )
    end
  end

  after_perform do |job|
    Tweet.create_indexes
    Reports::TweetDailyJob.perform_later(last_update)
    Reports::TweetHourJob.perform_later()
    Links::CreateJob.perform_later(last_update)
  end

  private

  def years_range
    ((last_update.year)..(Time.new.utc.year))
  end

  def default_last_update
    Time.parse(ENV['DATA_SINCE'] || "2018-01-1 00:00:00 UTC")
  end

  def last_update
    @last_update ||= Tweet.desc(:created_at).limit(1).first&.created_at || default_last_update
  end

  def new_tweet?(tweet)
    tweet[:created_at] > last_update
  end
end

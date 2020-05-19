require 'uri'

class Tweets::ImportJob < ApplicationJob
  def perform(*args)
    TrumpTwitterApi.new(last_update).get_new_tweets.each do |tweet|
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

  def last_update
    @last_update ||= Tweet.desc(:created_at).limit(1).first&.created_at || default_last_update
  end
end

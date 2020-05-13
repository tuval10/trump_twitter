require 'uri'
require 'twitter-text'

class Links::CreateJob < ApplicationJob
  include Twitter::TwitterText::Extractor

  def perform(last_updated_at)
    @last_updated_at = last_updated_at
    new_tweets(last_updated_at).each do |tweet|
      extract_urls(tweet.text).uniq.each do |url|
        tweet.links.create!(url: url, scanned: false, created_at: tweet.created_at)
      end
    end
  end

  after_perform do |job|
    Link.create_indexes
    Links::CountMentionsManagerJob.perform_later
  end

  private

  def new_tweets(last_updated_at)
    Tweet.where(:created_at.gt => last_updated_at)
  end
end

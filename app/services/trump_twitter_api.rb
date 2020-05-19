class TrumpTwitterApi
  def initialize(last_updated_at)
    @last_updated_at = last_updated_at
  end

  def get_new_tweets
    return to_enum(:get_new_tweets) unless block_given?
    years_range.each do |year|
      get_new_tweets_per_year(year).each do |tweet|
        yield tweet
      end
    end
  end

  private

  def years_range
    ((@last_updated_at.year)..(Time.new.utc.year))
  end

  def new_tweet?(tweet_json)
    tweet_json[:created_at] > @last_updated_at
  end

  def get_new_tweets_per_year(year)
    get_tweets_json_per_year(year)
      .map(&:symbolize_keys)
      .map(&method(:time_str_to_utc))
      .select {|tweet| new_tweet?(tweet)}
  end

  def get_tweets_json_per_year(year)
    url = URI.parse("#{ENV['API_URL']}/#{year}.json")
    HTTParty.get(url).parsed_response
  end

  def time_str_to_utc(tweet_json)
    tweet_json[:created_at] = Time.parse(tweet_json[:created_at]).utc
    tweet_json
  end
end
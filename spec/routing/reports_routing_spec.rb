require "rails_helper"

RSpec.describe ReportsController, type: :routing do
  describe "routing" do
    it "routes to #tweets_by_minute" do
      expect(get: "/trump_twitter_api/1.0.0/tweets_by_minute").to route_to("reports#tweets_by_minute")
    end

    it "routes to #tweets_daily" do
      expect(get: "/trump_twitter_api/1.0.0/tweets_daily").to route_to("reports#tweets_daily")
    end

    it "routes to #words_daily" do
      expect(get: "/trump_twitter_api/1.0.0/words_daily").to route_to("reports#words_daily")
    end
  end
end

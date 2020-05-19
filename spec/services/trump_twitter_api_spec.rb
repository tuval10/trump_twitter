require 'rails_helper'

describe TrumpTwitterApi do
  let (:year_2018) {Time.parse("2018-01-01 00:00:00 UTC")}
  let (:year_2019) {Time.parse("2019-01-01 00:00:00 UTC")}
  let (:year_2020) {Time.parse("2020-01-01 00:00:00 UTC")}
  let (:api) { TrumpTwitterApi.new(year_2018)}
  let (:api_response) {{
    "created_at" => "Mon Dec 31 23:53:06 +0000 2018",
    "favorite_count" => 136012,
    "id_str" => "1079888205351145472",
    "in_reply_to_user_id_str" => nil,
    "is_retweet" => false,
    "retweet_count" => 33548,
    "source" => "Twitter for iPhone",
    "text" => "HAPPY NEW YEAR! https://t.co/bHoPDPQ7G6",
  }}
  let (:api_response_parsed) {{
    created_at:  Time.parse('2018-12-31 23:53:06 UTC'),
    favorite_count: 136012,
    id_str: "1079888205351145472",
    in_reply_to_user_id_str: nil,
    is_retweet: false,
    retweet_count: 33548,
    source: "Twitter for iPhone",
    text: "HAPPY NEW YEAR! https://t.co/bHoPDPQ7G6",
  }}

  let (:api_response_parsed_2019) {{
    created_at:  Time.parse('2019-12-31 23:53:06 UTC'),
    favorite_count: 136013,
    id_str: "1079888205351145471",
    in_reply_to_user_id_str: nil,
    is_retweet: true,
    retweet_count: 3358,
    source: "Twitter for iPhone",
    text: "new api response tweet",
  }}


  describe '#years_range' do
    it 'returns years range since last_updated_at' do
      Timecop.freeze(year_2018) do
        expect(api.send(:years_range).to_a).to eq([2018])
      end

      Timecop.freeze(year_2020) do
        expect(api.send(:years_range).to_a).to eq([2018, 2019, 2020])
      end
    end
  end

  describe '#time_str_to_utc' do
    it 'returns tweet time in utc' do
      result = api.send(:time_str_to_utc, {created_at: "2018-01-02 00:00:00 + 02:00"})
      expect(result[:created_at].to_s).to eq('2018-01-01 22:00:00 UTC')
    end

    it 'works for response format' do
      result = api.send(:time_str_to_utc, {created_at: api_response['created_at']})
      expect(result[:created_at].to_s).to eq('2018-12-31 23:53:06 UTC')
    end
  end

  describe '#new_tweet?' do
    it 'returns true for new tweet' do
      expect(api.send(:new_tweet?, {created_at: Time.parse("2018-01-02 00:00:00 UTC")})).to be_truthy
    end

    it 'returns false for old tweet' do
      expect(api.send(:new_tweet?, {created_at: Time.parse("2017-12-30 23:59:59 UTC")})).to be_falsey
    end
  end

  describe '#get_tweets_json_per_year', :vcr do
    it 'get all jsons per year' do
      result = api.send(:get_tweets_json_per_year, 2018)
      expect(result.length).to eq(3510)
      expect(result[0]).to eq(api_response)
    end
  end

  describe '#get_new_tweets_per_year', :vcr do
    it 'transforms tweets in json response' do
      expect(api).to receive(:get_tweets_json_per_year).with(2018).and_return([api_response])
      result = api.send(:get_new_tweets_per_year, 2018)
      expect(result[0]).to eq(api_response_parsed)
    end

    it 'filters old results' do
      old_api_response = api_response.merge("created_at" => "Mon Dec 31 23:53:06 +0000 2017")
      expect(api).to receive(:get_tweets_json_per_year).with(2018).and_return([old_api_response])
      result = api.send(:get_new_tweets_per_year, 2018)
      expect(result.length).to eq(0)
    end
  end

  describe '#get_new_tweets_per_year', :vcr do
    it 'transforms tweets in json response' do
      expect(api).to receive(:get_new_tweets_per_year).with(2018).and_return([api_response_parsed])
      expect(api).to receive(:get_new_tweets_per_year).with(2019).and_return([api_response_parsed_2019])
      Timecop.freeze(year_2019) do
        expect { |b| api.get_new_tweets(&b) }.to yield_successive_args(api_response_parsed, api_response_parsed_2019)
      end
    end
  end

  it 'returns enumerator if block not given' do
    expect(api).to receive(:get_new_tweets_per_year).with(2018).and_return([api_response_parsed])
    expect(api).to receive(:get_new_tweets_per_year).with(2019).and_return([api_response_parsed_2019])
    Timecop.freeze(year_2019) do
      expect(api.get_new_tweets.to_a).to eq([api_response_parsed, api_response_parsed_2019])
    end
  end
end

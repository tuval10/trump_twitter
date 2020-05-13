require 'rails_helper'

RSpec.describe Reports::TweetDailyJob, type: :job do
  let(:job) {described_class.new}

  before(:each){
    @today_start = Date.today.beginning_of_day
    @today_end = Date.today.end_of_day
    @yesterday_end = @today_end - 1.day

    @tweets = [
      create(:tweet, created_at: @today_start),
      create(:tweet, created_at: @today_end),
      create(:tweet, created_at: @yesterday_end)
    ]
    @retweets = [
      create(:retweet, created_at: @today_start),
      create(:retweet, created_at: @yesterday_end),
      create(:retweet, created_at: @yesterday_end)
    ]
  }


  it {is_expected.to be_processed_in :reports}

  describe '#new_tweets' do
    it 'returns tweets and retweets from new dates' do
      expect(job.send(:new_tweets, @yesterday_end).count).to eq 6
      expect(job.send(:new_tweets, @today_start).count).to eq 3
      expect(job.send(:new_tweets, @today_end).count).to eq 3
    end
  end

  describe '#date_range' do
    it 'returns date range' do
      three_days_before = Time.now - 3.days
      result = job.send(:date_range, three_days_before)
      expect(result.to_a).to eq([Date.today - 3.days, Date.today - 2.days, Date.today - 1.days, Date.today])
    end
  end

  describe '#tally_by_date' do
    it 'returns collections count by created_at dates' do
      expected_tweets_by_day = {
        Date.today => 2,
        Date.today - 1.day => 1
      }
      expected_retweets_by_day = {
        Date.today => 1,
        Date.today - 1.day => 2
      }
      expect(job.send(:tally_by_date, @tweets, @retweets)).to eq ([expected_tweets_by_day, expected_retweets_by_day])
    end
  end


  describe '#performs' do
    it 'create daily reports' do
      two_days_ago = Date.today.middle_of_day - 2.days
      expect{job.perform(two_days_ago)}.to change{Reports::TweetDailyReport.count}.by(3)
      result = Reports::TweetDailyReport.all.as_json(except: '_id')
      expected = [
        {date: two_days_ago.beginning_of_day.to_datetime.strftime("%FT%T.%LZ"), tweets: 0, retweets: 0},
        {date: @yesterday_end.beginning_of_day.to_datetime.strftime("%FT%T.%LZ"), tweets: 1, retweets: 2},
        {date: @today_start.to_datetime.strftime("%FT%T.%LZ"), tweets: 2, retweets: 1},
      ].map(&:stringify_keys)
      expect{job.perform(two_days_ago)}.to change{Reports::TweetDailyReport.count}.by(3)
      expect(result).to eq(expected)
    end
  end
end

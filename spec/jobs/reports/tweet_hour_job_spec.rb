require 'rails_helper'

RSpec.describe Reports::TweetHourJob, type: :job do
  let(:job) {described_class.new}
  it {is_expected.to be_processed_in :reports}


  describe '#performs' do
    it 'create hourly  reports' do
      time = '2001-03-30T19:02:22'.to_datetime
      same_time_different_date = '2001-03-31T19:02:22'.to_datetime
      time2 = '2001-03-30T18:30:00'.to_datetime

      create(:tweet, created_at: time)
      create(:tweet, created_at: same_time_different_date)
      create(:tweet, created_at: time2)
      expect{job.perform}.to change{Reports::TweetHourReport.count}.by(2)
      expect(Reports::TweetHourReport.find_by(date: Time.parse("2018-01-01 19:02:00 UTC"))&.tweets).to eq 2
      expect(Reports::TweetHourReport.find_by(date: Time.parse("2018-01-01 18:30:00 UTC"))&.tweets).to eq 1
    end

    it 'take timezones to accounts' do
      time = '2001-03-30T19:00:00-05:00'.to_datetime
      create(:tweet, created_at: time)
      expect{job.perform}.to change{Reports::TweetHourReport.count}.by(1)
      expect(Reports::TweetHourReport.find_by(date: Time.parse("2018-01-01 00:00:00 UTC"))&.tweets).to eq 1
    end
  end
end

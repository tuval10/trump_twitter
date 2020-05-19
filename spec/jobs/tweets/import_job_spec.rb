require 'rails_helper'

describe Tweets::ImportJob, type: :job do
  include ActiveJob::TestHelper
  let(:job) {described_class.new}
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

  it {is_expected.to be_processed_in :default}

  describe '#last_update' do
    it 'returns default datetime if no records' do
      expected = Time.parse("2018-01-1 00:00:00 UTC")
      expect(job.send(:last_update)).to eq(expected)
    end

    it 'gets last update if tweets exists' do
      tweet1 = create(:tweet)
      tweet2 = create(:tweet, created_at: tweet1.created_at + 1.day)
      expect(job.send(:last_update)).to eq(tweet2.created_at)
    end

    it 'not getting set after initialization' do
      tweet1 = create(:tweet)
      tweet2 = create(:tweet, created_at: tweet1.created_at + 1.day)
      expect(job.send(:last_update)).to eq(tweet2.created_at)
      create(:tweet, created_at: tweet2.created_at + 1.day)
      expect(job.send(:last_update)).to eq(tweet2.created_at)
    end
  end

  describe '#perform' do
    it 'creates new tweets from api response' do
      expect_any_instance_of(TrumpTwitterApi).to receive(:get_new_tweets).and_return([api_response_parsed])
      expect {job.perform}.to change {Tweet.count}.by(1)
    end
  end

  it 'calls next jobs after finishing' do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    expected_last_update = Time.parse("2018-01-1 00:00:00 UTC")
    expect_any_instance_of(Tweets::ImportJob).to receive(:perform)
    expect_any_instance_of(Reports::TweetDailyJob).to receive(:perform).with(expected_last_update)
    expect_any_instance_of(Reports::TweetHourJob).to receive(:perform)
    expect_any_instance_of(Links::CreateJob).to receive(:perform).with(expected_last_update)
    Tweets::ImportJob.perform_later(Time.now)
    clear_enqueued_jobs
    clear_performed_jobs
  end
end

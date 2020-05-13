require 'rails_helper'

RSpec.describe Tweets::ImportJob, type: :job do
  include ActiveJob::TestHelper
  let(:job) {described_class.new}

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

  describe '#years_range' do
    it 'returns years range since default change if no tweets' do
      Timecop.freeze(Time.parse("2018-01-1 00:00:00 UTC")) do
        expect(job.send(:years_range).to_a).to eq([2018])
      end

      Timecop.freeze(Time.parse("2020-01-1 00:00:00 UTC")) do
        expect(job.send(:years_range).to_a).to eq([2018, 2019, 2020])
      end
    end

    it 'returns years range since last change if there is tweets' do
      Timecop.freeze(Time.parse("2020-01-1 00:00:00 UTC")) do
        tweet = create(:tweet)
        expect(tweet.created_at.year).to eq(2020)
        expect(job.send(:years_range).to_a).to eq([2020])
      end
    end
  end

  describe '#new_tweet?' do
    it 'returns true for new tweet' do
      old_tweet = create(:tweet)
      expect(job.send(:last_update)).to eq(old_tweet.created_at)
      new_tweet = create(:tweet, created_at: old_tweet.created_at + 1.day)
      expect(job.send(:new_tweet?, new_tweet)).to be_truthy
    end

    it 'returns false for old tweet' do
      old_tweet = create(:tweet)
      new_tweet = create(:tweet, created_at: old_tweet.created_at + 1.day)
      expect(job.send(:last_update)).to eq(new_tweet.created_at)
      expect(job.send(:new_tweet?, old_tweet)).to be_falsey
    end
  end

  describe '#perform_for_year', :vcr do
    it 'creates new records' do
      job.perform_for_year(2018)
      expect(Tweet.count).to eq(3510)
    end

    it 'creates only new records' do
      create(:tweet, created_at: Time.parse("2018-12-29 00:00:00 UTC"))
      job.perform_for_year(2018)
      expect(Tweet.count).to eq(25)
    end
  end

  describe '#perform' do
    it 'calls #perform_for_years' do
      Timecop.freeze(Time.parse("2020-01-1 00:00:00 UTC")) do
        expect(job).to receive(:perform_for_year).with(2018)
        expect(job).to receive(:perform_for_year).with(2019)
        expect(job).to receive(:perform_for_year).with(2020)
        job.perform
      end
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

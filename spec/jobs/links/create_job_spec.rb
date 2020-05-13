require 'rails_helper'

RSpec.describe Links::CreateJob, type: :job do
  include ActiveJob::TestHelper
  let(:job) {described_class.new(Time.now - 1.day)}
  it {is_expected.to be_processed_in :default}

  describe '#new_tweets' do
    it 'filters old tweets' do
      create(:tweet, created_at: Time.now - 2.day)
      expect(job.send(:new_tweets, Time.now - 1.day).count).to eq(0)
    end

    it 'returns new tweets' do
      create(:tweet, created_at: Time.now)
      expect(job.send(:new_tweets, Time.now - 1.day).count).to eq(1)
    end
  end

  describe '#performs' do
    it 'creates new links' do
      tweet = create(:tweet, text: 'we have two links www.google.com and also https://t.co/KO8E3bfWfn nice!', created_at: Time.now)
      expect{job.perform(Time.now - 1.day)}.to change{Link.count}.by(2)
      expect(tweet.reload.links.map(&:url)).to eq(['www.google.com', 'https://t.co/KO8E3bfWfn'])
    end

    it 'does not create duplicate links' do
      tweet = create(:tweet, text: 'we have two same links www.yahoo.com and also www.yahoo.com why?', created_at: Time.now)
      expect{job.perform(Time.now - 1.day)}.to change{Link.count}.by(1)
      expect(tweet.reload.links.map(&:url)).to eq(['www.yahoo.com'])
    end
  end

  describe 'after_perform' do
    it 'calls Links::CountMentionsManagerJob.perform_later after finishing' do
      ActiveJob::Base.queue_adapter = :test
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      expect_any_instance_of(Links::CountMentionsManagerJob).to receive(:perform)
      described_class.perform_later(Time.new)
      clear_enqueued_jobs
      clear_performed_jobs
    end
  end
end

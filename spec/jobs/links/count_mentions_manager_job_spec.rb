require 'rails_helper'

RSpec.describe Links::CountMentionsManagerJob, type: :job do
  include ActiveJob::TestHelper
  let(:job) {described_class.new}
  it {is_expected.to be_processed_in :manager}

  describe '#new_links' do
    it 'filters old tweets' do
      create(:fetched_link, created_at: Time.now - 2.day)
      expect(job.send(:new_links, Time.now - 1.day).count).to eq(0)
    end

    it 'returns new tweets' do
      create(:fetched_link, created_at: Time.now)
      expect(job.send(:new_links, Time.now - 1.day).count).to eq(1)
    end
  end

  it 'calls Links::CountMentionsJob.perform_later after finishing' do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    link = create(:fetched_link)
    expect_any_instance_of(Links::CountMentionsJob).to receive(:perform).with(link.id.to_s)
    described_class.perform_later
    clear_enqueued_jobs
    clear_performed_jobs
  end
end

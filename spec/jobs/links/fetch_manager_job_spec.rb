require 'rails_helper'

RSpec.describe Links::FetchManagerJob, type: :job do
  include ActiveJob::TestHelper
  let(:job) {described_class.new}
  it {is_expected.to be_processed_in :manager}

  describe '#new_links' do
    it 'filters fetched links' do
      create(:link, fetched: true)
      expect(job.send(:new_links).count).to eq(0)
    end

    it 'returns new links' do
      create(:link)
      expect(job.send(:new_links).count).to eq(1)
    end
  end

  it 'calls Links::CountMentionsJob.perform_later after finishing' do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    link = create(:link)
    expect_any_instance_of(Links::FetchJob).to receive(:perform).with(link.id.to_s)
    described_class.perform_later
    clear_enqueued_jobs
    clear_performed_jobs
  end
end

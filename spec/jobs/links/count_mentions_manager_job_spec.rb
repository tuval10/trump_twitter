require 'rails_helper'

RSpec.describe Links::CountMentionsManagerJob, type: :job do
  include ActiveJob::TestHelper
  let(:job) {described_class.new}
  it {is_expected.to be_processed_in :manager}

  describe '#unscanned_links_ids' do
    it 'filters scanned links' do
      create(:scanned_link)
      expect(job.send(:unscanned_links_ids).count).to eq(0)
    end

    it 'returns unscanned links ids' do
      link = create(:link)
      expect(job.send(:unscanned_links_ids)).to eq([link.id.to_s])
    end
  end

  it 'calls Links::CountMentionsJob.perform_later after finishing' do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    link = create(:link)
    expect_any_instance_of(Links::CountMentionsJob).to receive(:perform).with(link.id.to_s)
    described_class.perform_later
    clear_enqueued_jobs
    clear_performed_jobs
  end
end

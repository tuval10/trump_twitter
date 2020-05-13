require 'rails_helper'

RSpec.describe Links::FetchJob, type: :job do
  include ActiveJob::TestHelper
  let(:job) {described_class.new}
  it {is_expected.to be_processed_in :default}

  describe '#perform' do
    it 'knows to handle utf8', :vcr do
      url = 'https://t.co/6cRDaMnVUV'
      link = create(:link, url: url)
      expect{job.perform(link.id.to_s)}.to change{Link.where(fetched: true).count}.by(1)
    end
  end

  describe '#update_link_body' do
    it 'updates body' do
      link = create(:link)
      job.send(:update_link_body , link, 'stub body')
      expect(link.body).to eq('stub body')
      expect(link.fetched).to be_truthy
    end

    it 'handles mongoid errors' do
      link = create(:link)
      error = Mongoid::Errors::MongoidError.new("error")
      allow(link).to receive(:update_attributes!).and_raise(error)
      expect(Rollbar).to receive(:error).with(error, job: 'Links::FetchJob', link: link)
      job.send(:update_link_body , link, 'stub body')
      expect(link.body).to be_nil
      expect(link.fetched).to be_falsey
    end
  end


  describe '#fetch_url' do
    it 'fetch and returns body', :vcr do
      result = job.send(:fetch_url, 'www.google.com')
      expect(result.length).to eq(14516)
      expect(result).to include('<!doctype html>')
    end

    it 'returns nil on non exist domain - socket errror', :vcr do
      result = job.send(:fetch_url, 'http://asd.vcxvxcv.ccc/')
      expect(result).to be_nil
    end

    it 'returns nil on faulty status code', :vcr do
      result = job.send(:fetch_url, 'https://httpstat.us/404')
      expect(result).to be_nil
    end
  end
end

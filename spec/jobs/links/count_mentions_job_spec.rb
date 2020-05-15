require 'rails_helper'

RSpec.describe Links::CountMentionsJob, type: :job do
  let(:job) {described_class.new(Time.now - 1.day)}
  let(:body) {"<html><body><div>this paragraph contains conspiracy</div><div>and this contains conspiracy & russia</div></body></html>"}
  it {is_expected.to be_processed_in :default}

  describe '#keywords' do
    it 'returns keywords set' do
      expect(job.send(:keywords)).to eq(%w[conspiracy russia scandal outrage china].to_set)
    end
  end

  describe '#get_text' do
    it 'extract text from html' do
      expected = "this paragraph contains conspiracy and this contains conspiracy & russia"
      expect(job.send(:get_text, body)).to eq(expected)
    end
  end

  describe '#get_words_tally' do
    it 'counts words' do
      expect(job.send(:get_words_tally, body)).to eq({conspiracy: 2, russia: 1}.stringify_keys)
    end

    it 'ignore capitals' do
      expect(job.send(:get_words_tally, body.gsub('conspiracy', 'Conspiracy'))).to eq({conspiracy: 2, russia: 1}.stringify_keys)
    end
  end


  describe '#fetch_url' do
    it 'fetch and returns body', :vcr do
      result = job.send(:fetch_url, 'www.google.com')
      expect(result).to include('<!doctype html>')
    end
  end

  describe '#perform' do
    it 'creates word mentions and mark link as scanned', :vcr do
      link = create(:link, url: 'https://en.wikipedia.org/wiki/List_of_conspiracy_theories')
      expect {job.perform(link.id.to_s)}.to change {link.word_mentions.count}.by(3)
      conspiracy_mention = link.word_mentions.find_by(term: 'conspiracy')
      expect(conspiracy_mention.count).to eq(246)
      expect(conspiracy_mention.created_at.utc.to_s).to eq(link.created_at.utc.to_s)
      expect(link.word_mentions.find_by(term: 'russia').count).to eq(4)
      expect(link.word_mentions.find_by(term: 'scandal').count).to eq(7)
      expect(link.reload.scanned).to be_truthy
    end

    it 'catches socket errror', :vcr do
      link = create(:link, url: 'http://asd.vcxvxcv.ccc/')
      expect(Rollbar).to receive(:warning)
      expect {job.perform(link.id.to_s)}.to change {Link.where(scanned: true, error: true).count}.by(1)
    end

    it 'catches link not found error' do
      expect(Rollbar).to receive(:warning)
      job.perform("unknown_id")
    end

    it 'catches and report faulty status code', :vcr do
      link = create(:link, url: 'https://httpstat.us/404')
      expect(Rollbar).to receive(:warning)
      expect {job.perform(link.id.to_s)}.to change {Link.where(scanned: true, error: true).count}.by(1)
    end

    it 'catch argument error', :vcr do
      link = create(:link)
      allow(job).to receive(:get_text).and_raise(ArgumentError)
      expect(Rollbar).to receive(:warning)
      expect {job.perform(link.id.to_s)}.to change {Link.where(scanned: true, error: true).count}.by(1)
    end
  end
end

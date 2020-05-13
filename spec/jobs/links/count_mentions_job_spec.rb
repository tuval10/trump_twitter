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


  describe '#fetch_url' do
    it 'fetch and returns body', :vcr do
      result = job.send(:fetch_url, 'www.google.com')
      expect(result.length).to eq(14564)
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

    it 'ignore case' do
      link = create(:link)
      expect(job).to receive(:fetch_url).and_return('<html><body>conspiracy Conspiracy</body></html>')
      expect {job.perform(link.id.to_s)}.to change {link.word_mentions.count}.by(1)
      conspiracy_mention = link.word_mentions.find_by(term: 'conspiracy')
      expect(conspiracy_mention.count).to eq(2)
      expect(conspiracy_mention.created_at.utc.to_s).to eq(link.created_at.utc.to_s)
    end

    it 'knows to handle utf8', :vcr do
      url = 'https://t.co/6cRDaMnVUV'
      link = create(:link, url: url)
      expect {job.perform(link.id.to_s)}.to change {Link.where(scanned: true).count}.by(1)
    end
  end
end

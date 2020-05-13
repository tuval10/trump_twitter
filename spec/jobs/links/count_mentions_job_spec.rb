require 'rails_helper'

RSpec.describe Links::CountMentionsJob, type: :job do
  let(:job) {described_class.new(Time.now - 1.day)}
  it {is_expected.to be_processed_in :default}

  describe '#keywords' do
    it 'returns keywords set' do
      expect(job.send(:keywords)).to eq(%w[conspiracy russia scandal outrage china].to_set)
    end
  end

  describe '#get_text' do
    it 'extract text from html' do
      expected = "this paragraph contains conspiracy and this contains conspiracy & russia"
      expect(job.send(:get_text, create(:fetched_link))).to eq(expected)
    end
  end

  describe '#perform' do
    it 'returns keywords set' do
      link = create(:fetched_link, created_at: Time.now)
      expect{job.perform(link.id.to_s)}.to change{link.word_mentions.count}.by(2)
      conspiracy_mention = link.word_mentions.find_by(term: 'conspiracy')
      expect(conspiracy_mention.count).to eq(2)
      expect(conspiracy_mention.created_at.utc.to_s).to eq(link.created_at.utc.to_s)
      russia_mention = link.word_mentions.find_by(term: 'russia')
      expect(russia_mention.count).to eq(1)
      expect(russia_mention.created_at.utc.to_s).to eq(link.created_at.utc.to_s)
    end

    it 'ignore case' do
      link = create(:fetched_link, created_at: Time.now, body: '<html><body>conspiracy Conspiracy</body></html>')
      expect{job.perform(link.id.to_s)}.to change{link.word_mentions.count}.by(1)
      conspiracy_mention = link.word_mentions.find_by(term: 'conspiracy')
      expect(conspiracy_mention.count).to eq(2)
      expect(conspiracy_mention.created_at.utc.to_s).to eq(link.created_at.utc.to_s)
    end
  end
end

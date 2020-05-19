require 'rails_helper'

RSpec.describe Reports::WordsDailyJob, type: :job do
  let(:job) {described_class.new}

  before(:each) {
    @today_start = Date.today.beginning_of_day
    @today_end = Date.today.end_of_day
    @yesterday_end = @today_end - 1.day
  }


  it {is_expected.to be_processed_in :reports}

  describe '#last_update' do
    it 'returns default datetime if no records' do
      expected = Time.parse("2018-01-1 00:00:00 UTC")
      expect(job.send(:last_update)).to eq(expected)
    end

    it 'gets last report date if words daily report exists' do
      create(:words_daily_report, date: @yesterday_end)
      expect(job.send(:last_update).utc.to_s).to eq(@yesterday_end.utc.to_s)
    end

    it 'not getting set after initialization' do
      create(:words_daily_report, date: @yesterday_end)
      expect(job.send(:last_update).utc.to_s).to eq(@yesterday_end.utc.to_s)
      create(:words_daily_report, date: @today_end)
      expect(job.send(:last_update).utc.to_s).to eq(@yesterday_end.utc.to_s)
    end
  end

  describe '#new_word_mentions_by_date' do
    it 'filters old word mentions' do
      create(:word_mention, created_at: @yesterday_end)
      create(:words_daily_report, date: @today_start)
      expect(job.send(:new_word_mentions_by_date).count).to eq 0
    end

    it 'returns word mentions from same day' do
      create(:word_mention, created_at: @today_start)
      create(:words_daily_report, date: @today_end)
      expect(job.send(:new_word_mentions_by_date).count).to eq 1
    end

    it 'group mentions by dates' do
      create(:word_mention, created_at: @today_start)
      create(:word_mention, created_at: @today_end)
      result = job.send(:new_word_mentions_by_date)
      expect(result.count).to eq 1
      expect(result.first[1].count).to eq 2
    end
  end

  describe '#word_mentions_tally_by_date' do
    it 'create_tally_of_words_per_date' do
      create(:word_mention, term: 'russia', created_at: @today_start, count: 2)
      create(:word_mention, term: 'russia', created_at: @today_end, count: 5)
      create(:word_mention, term: 'conspiracy', created_at: @today_start, count: 13)
      create(:word_mention, term: 'russia', created_at: @yesterday_end, count: 8)
      expected = {
        @today_start.to_date => {
          "russia" => 7,
          "conspiracy" => 13
        },
        @yesterday_end.to_date => {
          "russia" => 8
        }
      }
      expect(job.send(:word_mentions_tally_by_date)).to eq expected
    end
  end


  describe '#performs' do
    it 'create daily reports' do
      create(:word_mention, term: 'russia', created_at: @today_start, count: 2)
      create(:word_mention, term: 'russia', created_at: @today_end, count: 5)
      create(:word_mention, term: 'conspiracy', created_at: @today_start, count: 13)
      create(:word_mention, term: 'russia', created_at: @yesterday_end, count: 8)
      expected = [
        {date: @yesterday_end.beginning_of_day.to_datetime.strftime("%FT%T.%LZ"), russia: 8},
        {date: @today_start.to_datetime.strftime("%FT%T.%LZ"), russia: 7, conspiracy: 13},
      ].map(&:stringify_keys)
      expect {job.perform}.to change {Reports::WordsDailyReport.count}.by(2)
      result = Reports::WordsDailyReport.all.as_json(except: '_id').map(&:compact)
      expect(result).to eq(expected)
    end
  end
end

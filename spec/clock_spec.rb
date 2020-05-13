require 'clockwork/test'
require 'rails_helper'

describe Clockwork do
  let(:file) {'./clock.rb'}
  after(:each) {Clockwork::Test.clear!}
  describe '#tweets.import' do

    it 'runs Tweets::ImportJob at midnight' do
      job = 'tweets.import'
      start_time = Time.new(2020,1,1,0,0,0)
      end_time = Time.new(2020,1,1,0,0,1)
      Clockwork::Test.run(start_time: start_time, end_time: end_time, tick_speed: 1.minute, file: file)
      expect(Clockwork::Test.times_run(job)).to eq 1
    end

    it 'runs Tweets::ImportJob every day at midnight' do
      job = 'tweets.import'
      start_time = Time.new(2020,1,1,0,0,0)
      end_time = Time.new(2020,1,4,0,0,0)
      Clockwork::Test.run(start_time: start_time, end_time: end_time, tick_speed: 1.hour, file: file)
      expect(Clockwork::Test.times_run(job)).to eq 3
    end

    it 'runs Links::CountMentionsJob every day at 1' do
      job = 'links.count_mentions'
      start_time = Time.new(2020,1,1,1,0,0)
      end_time = Time.new(2020,1,1,1,0,1)
      Clockwork::Test.run(start_time: start_time, end_time: end_time, tick_speed: 1.minute, file: file)
      expect(Clockwork::Test.times_run(job)).to eq 1
    end
  end
end
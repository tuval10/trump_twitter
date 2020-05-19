class Reports::WordsDailyJob < ApplicationJob
  sidekiq_options queue: 'reports'

  def perform
    word_mentions_tally_by_date.each do |date, word_mentions_tally|
      daily_report = Reports::WordsDailyReport.new(
        date: date.to_datetime,
      )
      word_mentions_tally.each do |word, count|
        daily_report[word] = count
      end
      daily_report.upsert
    end
  end

  private

  def last_update
    @last_update ||= Reports::WordsDailyReport.desc(:date).limit(1).first&.date || default_last_update
  end

  def word_mentions_tally_by_date
    create_words_tally = Proc.new do |mentions|
      mentions.each_with_object(Hash.new(0)) do |mention, words_tally|
        words_tally[mention.term] += mention.count
      end
    end
    new_word_mentions_by_date.transform_values(&create_words_tally)
  end

  def new_word_mentions_by_date
    WordMention.where(:created_at.gte => last_update.to_date.to_datetime)
      .group_by{|mention| mention.created_at.to_date}
  end
end

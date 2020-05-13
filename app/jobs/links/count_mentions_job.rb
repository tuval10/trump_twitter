require 'nokogiri'
class Links::CountMentionsJob < ApplicationJob
  def perform(link_id)
    is_keyword = Proc.new {|word| keywords.include?(word)}
    link = Link.find(link_id)
    get_text(link).scan(/\w+/).map(&:downcase).select(&is_keyword).tally.each do |term, count|
      link.word_mentions.create!(term: term, count: count, created_at: link.created_at)
    end
  end

  private

  def get_text(link)
    Nokogiri::HTML(link.body).xpath('.//text() | text()').map(&:inner_text).join(' ')
  end

  def keywords
    @keywords ||= ENV['KEYWORDS'].split(',').to_set
  end
end

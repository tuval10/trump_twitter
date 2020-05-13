require 'nokogiri'
class Links::CountMentionsJob < ApplicationJob
  def perform(link_id)
    link = Link.find(link_id)
    body = fetch_url(link.url)
    unless body.nil?
      is_keyword = Proc.new {|word| keywords.include?(word)}
      body = body.force_encoding('UTF-8')
      get_text(body).scan(/\w+/).map(&:downcase).select(&is_keyword).tally.each do |term, count|
        link.word_mentions.create!(term: term, count: count, created_at: link.created_at)
      end
    end
    link.update_attributes!(scanned: true)
  end

  private

  def fetch_url(url)
    url = "http://#{url}" if URI.parse(url).scheme.nil?
    response = HTTParty.get(url)
    unless response.ok?
      Rollbar.error("error status #{response.code}", job: 'Links::CountMentionsJob', url: url)
      return nil
    end
    if response.body.empty?
      Rollbar.error("empty body. status #{response.code}", job: 'Links::CountMentionsJob', url: url)
      return nil
    end
    response.body
  rescue HTTParty::Error, SocketError => e
    Rollbar.error(e, job: 'Links::CountMentionsJob', url: url)
    nil
  end

  def get_text(body)
    Nokogiri::HTML(body).xpath('.//text() | text()').map(&:inner_text).join(' ')
  end

  def keywords
    @keywords ||= ENV['KEYWORDS'].split(',').to_set
  end
end

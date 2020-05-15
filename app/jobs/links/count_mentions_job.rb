require 'nokogiri'
class Links::CountMentionsJob < ApplicationJob
  def perform(link_id)
    link = Link.find(link_id)
    body = fetch_url(link.url)
    unless body.nil?
      body = body.force_encoding('UTF-8')
      get_words_tally(body).each do |term, count|
        link.word_mentions.create!(term: term, count: count, created_at: link.created_at)
      end
    end
    link.update_attributes!(scanned: true)
  rescue Mongoid::Errors::DocumentNotFound => e
    Rollbar.warning(e, job: 'Links::CountMentionsJob', link_id: link_id)
  rescue HTTParty::Error, SocketError, OpenSSL::SSL::SSLError, ArgumentError => e
    Rollbar.warning(e, job: 'Links::CountMentionsJob', url: link&.url)
    link&.update_attributes!(scanned: true, error: true)
  end

  private

  def get_words_tally(body)
    is_keyword = Proc.new {|word| keywords.include?(word)}
    get_text(body).scan(/\w+/).map(&:downcase).select(&is_keyword).tally
  end

  def fetch_url(url)
    url = "http://#{url}" if URI.parse(url).scheme.nil?
    response = HTTParty.get(url)
    unless response.ok?
      raise HTTParty::ResponseError.new "error status #{response.code}"
    end
    if response.body.empty?
      raise HTTParty::ResponseError.new "empty body. status #{response.code}"
    end
    response.body
  end

  def get_text(body)
    Nokogiri::HTML(body).xpath('.//text() | text()').map(&:inner_text).join(' ')
  end

  def keywords
    @keywords ||= ENV['KEYWORDS'].split(',').to_set
  end
end

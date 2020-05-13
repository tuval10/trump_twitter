require 'uri'

class Links::FetchJob < ApplicationJob
  def perform(link_id)
    link = Link.find(link_id)
    body = fetch_url(link.url)
    unless body.nil?
      body = body.force_encoding('UTF-8')
      update_link_body(link, body)
    end
  end

  private

  def update_link_body(link, body)
    link.update_attributes!(body: body, fetched: true)
  rescue Mongoid::Errors::MongoidError => e
    Rollbar.error(e, job: 'Links::FetchJob', link: link)
  end

  def fetch_url(url)
    url = "http://#{url}" if URI.parse(url).scheme.nil?
    response = HTTParty.get(url)
    unless response.ok?
      Rollbar.error("error status #{response.code}", job: 'Links::FetchJob', url: url)
      return nil
    end
    if response.body.empty?
      Rollbar.error("empty body. status #{response.code}", job: 'Links::FetchJob', url: url)
      return nil
    end
    response.body
  rescue HTTParty::Error, SocketError => e
    Rollbar.error(e, job: 'Links::FetchJob', url: url)
    nil
  end
end

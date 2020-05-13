require 'nokogiri'
class Links::CountMentionsManagerJob < ApplicationJob
  sidekiq_options queue: 'manager'

  def perform(last_updated_at = nil)
    new_links(last_updated_at).pluck(:id).map(&:to_s).each do |link_id|
      Links::CountMentionsJob.perform_later(link_id)
    end
  end

  private

  def new_links(last_updated_at)
    links = Link.where(scanned: false, fetched: true)
    links = links.where(:created_at.gt => last_updated_at) unless last_updated_at.nil?
    links
  end
end

require 'nokogiri'
class Links::CountMentionsManagerJob < ApplicationJob
  sidekiq_options queue: 'manager'

  def perform(last_updated_at = nil)
    unscanned_links_ids.each do |link_id|
      Links::CountMentionsJob.perform_later(link_id)
    end
  end

  private

  def unscanned_links_ids
    Link.where(scanned: false).pluck(:id).map(&:to_s)
  end
end

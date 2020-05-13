require 'uri'

class Links::FetchManagerJob < ApplicationJob
  sidekiq_options queue: 'manager'

  def perform()
    new_links.pluck(:id).map(&:to_s).each do |link_id|
      Links::FetchJob.perform_later(link_id)
    end
  end

  private

  def new_links
    Link.where(fetched: false)
  end
end

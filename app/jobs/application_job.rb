class ApplicationJob < ActiveJob::Base
  sidekiq_options retry: 5

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def default_last_update
    Time.parse(ENV['DATA_SINCE'] || "2018-01-1 00:00:00 UTC")
  end
end

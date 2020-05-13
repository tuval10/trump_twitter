namespace :sidekiq do
  desc "Cleaning sidekiq"
  task clean: :environment do
    Sidekiq::Queue.all.each(&:clear)
    Sidekiq::RetrySet.new.clear
    Sidekiq::ScheduledSet.new.clear
    Sidekiq::DeadSet.new.clear
    Sidekiq::Stats.new.reset
  end

end

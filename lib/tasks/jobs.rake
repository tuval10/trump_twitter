namespace :jobs do
  desc "Start fetching the data"
  task start: :environment do
    Tweets::ImportJob.perform_later
  end
end

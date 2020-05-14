web: bundle exec puma -C ./config/puma.rb
worker: bundle exec sidekiq -C ./config/sidekiq.yml
next: cd client && yarn && yarn build && yarn start
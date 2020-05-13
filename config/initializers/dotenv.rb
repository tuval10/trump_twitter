Bundler.require(*Rails.groups)
if ['development', 'test'].include? ENV['RAILS_ENV']
  Dotenv.require_keys("API_URL", "KEYWORDS", "MONGODB_URI", "CLIENT_ENDPOINT", "REDISCLOUD_URL", "DATA_SINCE")
end
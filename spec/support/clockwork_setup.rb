require 'mongoid-rspec'

RSpec.configure do |config|
  config.include(Clockwork::Test::RSpec::Matchers)
end
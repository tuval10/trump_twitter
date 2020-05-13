require File.expand_path('../config/boot', __FILE__)
require File.expand_path('../config/environment', __FILE__)
require 'rubygems'
require 'clockwork'


module Clockwork
  every(1.day, 'tweets.import', at: '00:00') do
    ::Tweets::ImportJob.perform_later
  end

  every(1.day, 'links.count_mentions', at: '01:00') do
    Links::CountMentionsManagerJob.perform_later
  end
end
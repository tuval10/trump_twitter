=begin
Simple Inventory API

This is a simple API

OpenAPI spec version: 1.0.0
Contact: you@your-company.com
Generated by: https://github.com/swagger-api/swagger-codegen.git

=end


class Reports::TweetHourReport < Reports::BaseReport
  include Mongoid::Document
  field :tweets, type: Integer

  validates_presence_of :tweets
end

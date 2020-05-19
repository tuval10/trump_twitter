class Link < ApplicationRecord
  field :url, type: String
  field :scanned, type: Mongoid::Boolean, default: false
  field :error, type: Mongoid::Boolean, default: false

  belongs_to :tweet
  has_many :word_mentions, dependent: :destroy

  validates_uniqueness_of :url, :scope => :tweet_id
end

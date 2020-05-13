class Tweet < ApplicationRecord
  field :source, type: String
  field :id_str, type: String
  field :text, type: String
  field :retweet_count, type: Integer
  field :in_reply_to_user_id_str, type: String
  field :favorite_count, type: Integer
  field :is_retweet, type: Mongoid::Boolean

  has_many :links, dependent: :destroy
end

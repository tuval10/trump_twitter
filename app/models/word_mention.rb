class WordMention < ApplicationRecord
  field :term, type: String
  field :count, type: Integer
  belongs_to :link
end

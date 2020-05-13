class ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  index({created_at: -1}, {background: true})
end
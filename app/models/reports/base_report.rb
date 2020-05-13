class Reports::BaseReport
  include Mongoid::Document

  field :date, type: Time

  index({ date: 1 },{ background: true })

  default_scope -> { order(date: :asc) }

  validates_presence_of :date
end
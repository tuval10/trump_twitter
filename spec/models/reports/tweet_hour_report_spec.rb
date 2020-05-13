require 'rails_helper'

RSpec.describe Reports::TweetHourReport, type: :model do
  context 'Includes' do
    it do
      is_expected.to be_mongoid_document
    end
  end

  context 'Fields' do
    it do
      is_expected.to have_field(:_id).of_type(BSON::ObjectId)
      is_expected.to have_field(:tweets).of_type(Integer)
      is_expected.to have_field(:date).of_type(Time)
    end
  end

  context 'Indexes' do
    it do
      is_expected
        .to have_index_for(date: 1)
              .with_options(background: true)
    end
  end

  context 'Validations' do
    it {is_expected.to validate_presence_of(:tweets)}
    it {is_expected.to validate_presence_of(:date)}
  end
end

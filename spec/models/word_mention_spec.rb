require 'rails_helper'

RSpec.describe WordMention, type: :model do
  context 'Includes' do
    it do
      is_expected.to be_mongoid_document
      is_expected.to have_timestamps.for(:creating)
    end
  end

  context 'Fields' do
    it do
      is_expected.to have_field(:_id).of_type(BSON::ObjectId)
      is_expected.to have_field(:term).of_type(String)
      is_expected.to have_field(:count).of_type(Integer)
      is_expected.to have_field(:link_id).of_type(Object)
      is_expected.to have_field(:created_at).of_type(Time)
    end
  end

  context 'Associations' do
    it do
      is_expected.to belong_to(:link).of_type(Link)
    end
  end

  context 'Indexes' do
    it do
      is_expected
        .to have_index_for(created_at: -1)
              .with_options(background: true)
    end
  end
end

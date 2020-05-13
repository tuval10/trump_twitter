require 'rails_helper'

RSpec.describe Tweet, type: :model do
  context 'Includes' do
    it do
      is_expected.to be_mongoid_document
      is_expected.to have_timestamps.for(:creating)
    end
  end

  context 'Fields' do
    it do
      is_expected.to have_field(:_id).of_type(BSON::ObjectId)
      is_expected.to have_field(:source).of_type(String)
      is_expected.to have_field(:id_str).of_type(String)
      is_expected.to have_field(:text).of_type(String)

      is_expected.to have_field(:retweet_count).of_type(Integer)
      is_expected.to have_field(:in_reply_to_user_id_str).of_type(String)
      is_expected.to have_field(:favorite_count).of_type(Integer)
      is_expected.to have_field(:is_retweet).of_type(Mongoid::Boolean)
      is_expected.to have_field(:created_at).of_type(Time)
    end
  end

  context 'Associations' do
    it do
      is_expected.to have_many(:links).of_type(Link).with_dependent(:destroy)
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

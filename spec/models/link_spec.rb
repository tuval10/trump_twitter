require 'rails_helper'

RSpec.describe Link, type: :model do
  context 'Includes' do
    it do
      is_expected.to be_mongoid_document
      is_expected.to have_timestamps.for(:creating)
    end
  end

  context 'Fields' do
    it do
      is_expected.to have_field(:_id).of_type(BSON::ObjectId)
      is_expected.to have_field(:body).of_type(String)
      is_expected.to have_field(:url).of_type(String)
      is_expected.to have_field(:tweet_id).of_type(Object)
      is_expected.to have_field(:created_at).of_type(Time)
      is_expected.to have_field(:fetched).of_type(Mongoid::Boolean).with_default_value_of(false)
      is_expected.to have_field(:scanned).of_type(Mongoid::Boolean).with_default_value_of(false)
    end
  end

  context 'Associations' do
    it do
      is_expected.to belong_to(:tweet).of_type(Tweet)
      is_expected.to have_many(:word_mentions).of_type(WordMention).with_dependent(:destroy)
    end
  end

  context 'Indexes' do
    it do
      is_expected
        .to have_index_for(created_at: -1)
              .with_options(background: true)
    end
  end

  context 'Uniqueness' do
    it 'unique on tweet_id and url together' do
      tweet = create(:tweet)
      create(:link, tweet: tweet)
      expect do
        create(:link, tweet: tweet)
      end.to raise_error(Mongoid::Errors::Validations)
    end
  end
end

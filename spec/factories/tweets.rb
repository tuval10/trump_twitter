FactoryBot.define do
  factory :tweet do
    source { "Twitter for iPhone" }
    id_str { "1078396200842395648" }
    text { "I totally agree! https://t.co/KO8E3bfWfn" }
    created_at { "2020-05-09 17:51:05" }
    retweet_count { 45971 }
    in_reply_to_user_id_str { nil }
    favorite_count { 180032 }
    is_retweet { false }
  end

  factory :retweet, class: Tweet do
    source { "Twitter for iPhone" }
    id_str { "1078396200842395649" }
    text { "this is retweet what a shame" }
    created_at { "2020-05-09 17:51:05" }
    retweet_count { 45971 }
    in_reply_to_user_id_str { nil }
    favorite_count { 180032 }
    is_retweet { true }
  end
end
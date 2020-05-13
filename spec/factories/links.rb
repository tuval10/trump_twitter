FactoryBot.define do
  factory :link do
    url { "https://t.co/KO8E3bfWfn" }
    body { nil }
    fetched { false }
    scanned { false }
    created_at { "2020-05-09 17:51:05" }
    tweet
  end

  factory :fetched_link, class: Link do
    url { "https://www.conspiracy.com" }
    body { "<html><body><div>this paragraph contains conspiracy</div><div>and this contains conspiracy & russia</div></body></html>" }
    fetched { true }
    scanned { false }
    created_at { "2020-05-09 17:51:05" }
    tweet
  end
end

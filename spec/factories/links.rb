FactoryBot.define do
  factory :link do
    url {"https://t.co/KO8E3bfWfn"}
    scanned {false}
    error {false}
    created_at {"2020-05-09 17:51:05"}
    tweet
  end

  factory :scanned_link, class: Link do
    url {"https://www.conspiracy.com"}
    scanned {true}
    error {false}
    created_at {"2020-05-09 17:51:05"}
    tweet
  end
end

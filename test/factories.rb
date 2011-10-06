FactoryGirl.define do
  factory :policy, aliases: [:document] do
  end

  factory :published_policy, parent: :policy do
    editions { [FactoryGirl.build(:published_edition)] }
  end

  factory :draft_policy, parent: :policy do
    editions { [FactoryGirl.build(:draft_edition)] }
  end

  factory :publication do
  end

  factory :edition do
    document
    author
    title "edition-title"
    body  "edition-body"
  end

  factory :draft_edition, parent: :edition do
    state "draft"
  end

  factory :submitted_edition, parent: :edition do
    state "draft"
    submitted true
  end

  factory :published_edition, parent: :edition do
    state "published"
    submitted true
  end

  factory :archived_edition, parent: :edition do
    state "archived"
    submitted true
  end

  factory :fact_check_request do
    edition
    email_address "fact-checker@example.com"
  end

  factory :user do
    name "Daaaaaaave"
  end

  factory :policy_writer, parent: :user, aliases: [:author] do
    departmental_editor false
  end

  factory :departmental_editor, parent: :user do
    departmental_editor true
  end

  factory :attachment do
    name "whitepaper.pdf"
  end

  factory :topic do
    sequence(:name) { |index| "topic-#{index}" }
    description { Faker::Lorem.sentence }
  end

  factory :organisation do
    sequence(:name) { |index| "topic-#{index}" }
  end
end
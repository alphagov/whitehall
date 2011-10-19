FactoryGirl.define do
  factory :document_identity do
  end

  factory :policy, aliases: [:document] do
    document_identity
    author
    title "policy-title"
    body  "policy-body"
  end

  factory :publication do
    document_identity
    author
    title "publication-title"
    body  "publication-body"
  end

  factory :news_article do
    document_identity
    author
    title "news-title"
    body  "news-body"
  end

  factory :published_policy, parent: :policy do
    state "published"
    submitted true
  end

  factory :draft_policy, parent: :policy do
    state "draft"
  end

  factory :archived_policy, parent: :policy do
    state "archived"
    submitted true
  end

  factory :submitted_policy, parent: :policy do
    state "draft"
    submitted true
  end

  factory :published_publication, parent: :publication do
    state "published"
    submitted true
  end

  factory :draft_publication, parent: :publication do
    state "draft"
  end

  factory :archived_publication, parent: :publication do
    state "archived"
    submitted true
  end

  factory :submitted_publication, parent: :publication do
    state "draft"
    submitted true
  end

  factory :draft_news_article, parent: :news_article do
    state "draft"
  end

  factory :submitted_news_article, parent: :news_article do
    state "draft"
    submitted true
  end

  factory :published_news_article, parent: :news_article do
    state "published"
    submitted true
  end

  factory :archived_news_article, parent: :news_article do
    state "archived"
    submitted true
  end

  factory :fact_check_request do
    document
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
    sequence(:name) { |index| "organisation-#{index}" }
  end

  factory :ministerial_role, aliases: [:role] do
    name "Parliamentary Under-Secretary of State"
  end

  factory :role_appointment do
    role
    person
    started_at 1.day.ago
  end

  factory :person do
    name "George"
  end

  factory :supporting_document do
    title "Something Supportive"
    body "Some supporting information"
    document
  end
end
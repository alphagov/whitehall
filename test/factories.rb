FactoryGirl.define do
  factory :document_identity do
  end

  factory :document do
    document_identity
    author
    title "document-title"
    body  "document-body"
  end

  factory :policy do
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

  factory :role do
    name "Parliamentary Under-Secretary of State"
  end

  factory :person do
    name "George"
  end
end
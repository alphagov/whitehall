FactoryGirl.define do
  factory :policy do
  end

  factory :edition do
    policy
    author
    title 'edition-title'
    body  'edition-body'
  end

  factory :draft_edition, parent: :edition do
    state 'draft'
  end

  factory :submitted_edition, parent: :edition do
    state 'draft'
    submitted true
  end

  factory :published_edition, parent: :edition do
    state 'published'
    submitted true
  end

  factory :archived_edition, parent: :edition do
    state 'archived'
  end

  factory :fact_check_request do
    edition
    email_address 'fact-checker@example.com'
  end

  factory :user do
    name 'Daaaaaaave'
  end

  factory :policy_writer, parent: :user, aliases: [:author] do
    departmental_editor false
  end

  factory :departmental_editor, parent: :user do
    departmental_editor true
  end
end
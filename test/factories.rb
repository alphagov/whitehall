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
  end

  factory :archived_edition, parent: :edition do
    state 'archived'
  end

  factory :user, aliases: [:author] do
    name 'Daaaaaaave'
  end

  factory :policy_writer, parent: :user do
    departmental_editor false
  end

  factory :departmental_editor, parent: :user do
    departmental_editor true
  end
end
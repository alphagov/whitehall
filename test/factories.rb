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
    submitted false
  end

  factory :submitted_edition, parent: :edition do
    submitted true
  end

  factory :published_edition, parent: :edition do
    published true
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
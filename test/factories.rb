FactoryGirl.define do
  factory :policy do
    author
    title 'policy-title'
    body  'policy-body'
  end

  factory :draft_policy, parent: :policy do
    submitted false
  end
  
  factory :submitted_policy, parent: :policy do
    submitted true
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
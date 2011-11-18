FactoryGirl.define do
  sequence :name do |n|
    "user-#{n}"
  end

  factory :user do
    name
  end

  factory :policy_writer, parent: :user, aliases: [:author, :creator, :fact_check_requestor] do
    departmental_editor false
  end

  factory :departmental_editor, parent: :user do
    departmental_editor true
  end
end
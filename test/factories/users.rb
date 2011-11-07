FactoryGirl.define do
  factory :user do
    name "Daaaaaaave"
  end

  factory :policy_writer, parent: :user, aliases: [:author, :fact_check_requestor] do
    departmental_editor false
  end

  factory :departmental_editor, parent: :user do
    departmental_editor true
  end
end
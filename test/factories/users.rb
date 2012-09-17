FactoryGirl.define do
  sequence :name do |n|
    "user-#{n}"
  end

  sequence :email do |n|
    "user-#{n}@example.com"
  end

  factory :user do
    name
    email
    permissions { Hash[GDS::SSO::Config.default_scope => ["signin"]] }
  end

  factory :policy_writer, parent: :user, aliases: [:author, :creator, :fact_check_requestor] do
  end

  factory :departmental_editor, parent: :user do
    permissions { Hash[GDS::SSO::Config.default_scope => ["signin", "Editor"]] }
  end
end
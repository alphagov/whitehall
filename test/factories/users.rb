FactoryGirl.define do
  sequence :name do |n|
    "user-#{n}"
  end

  sequence :email do |n|
    "user-#{n}@example.com"
  end

  sequence :uid do |n|
    "uid-#{n}"
  end

  factory :user do
    name
    email
    uid
    permissions { [User::Permissions::SIGNIN] }
  end

  factory :policy_writer, parent: :user, aliases: [:author, :creator, :fact_check_requestor] do
  end

  factory :departmental_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::DEPARTMENTAL_EDITOR] }
  end

  factory :managing_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::MANAGING_EDITOR] }
  end

  factory :scheduled_publishing_robot, parent: :user do
    uid nil
    name "Scheduled Publishing Robot"
    permissions { [User::Permissions::SIGNIN, User::Permissions::PUBLISH_SCHEDULED_EDITIONS] }
  end

  factory :gds_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::GDS_EDITOR] }
  end

  factory :importer, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::IMPORT] }
  end

  factory :world_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::WORLD_EDITOR] }
  end

  factory :world_writer, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::WORLD_WRITER] }
  end
end

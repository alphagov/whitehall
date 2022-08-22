FactoryBot.define do
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

  factory :disabled_user, parent: :user do
    disabled { true }
  end

  factory :writer, parent: :user, aliases: %i[author creator fact_check_requestor] do
  end

  factory :vip_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::VIP_EDITOR] }
  end

  factory :departmental_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::DEPARTMENTAL_EDITOR] }
  end

  factory :managing_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::MANAGING_EDITOR] }
  end

  factory :scheduled_publishing_robot, parent: :user do
    uid { nil }
    name { "Scheduled Publishing Robot" }
    permissions { [User::Permissions::SIGNIN, User::Permissions::PUBLISH_SCHEDULED_EDITIONS] }
  end

  factory :gds_admin, parent: :user do
    permissions do
      [User::Permissions::SIGNIN,
       User::Permissions::GDS_EDITOR,
       User::Permissions::GDS_ADMIN]
    end
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

  factory :export_data_user, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::EXPORT_DATA] }
  end

  factory :gds_team_user, parent: :user do
    name { "GDS Inside Government Team" }
    email { "govuk-whitehall@digital.cabinet-office.gov.uk" }
    permissions do
      [
        User::Permissions::SIGNIN,
        User::Permissions::DEPARTMENTAL_EDITOR,
        User::Permissions::GDS_EDITOR,
        User::Permissions::FORCE_PUBLISH_ANYTHING,
      ]
    end
  end

  factory :departmental_editor_with_preview_design_system, parent: :user do
    permissions do
      [
        User::Permissions::SIGNIN,
        User::Permissions::GDS_EDITOR,
        User::Permissions::DEPARTMENTAL_EDITOR,
        User::Permissions::PREVIEW_DESIGN_SYSTEM,
      ]
    end
  end
end

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

    trait(:with_preview_design_system) do
      permissions { [User::Permissions::SIGNIN, User::Permissions::PREVIEW_DESIGN_SYSTEM] }
    end

    trait(:with_use_non_legacy_endpoints) do
      permissions { [User::Permissions::SIGNIN, User::Permissions::USE_NON_LEGACY_ENDPOINTS] }
    end
  end

  factory :disabled_user, parent: :user do
    disabled { true }
  end

  factory :writer, parent: :user, aliases: %i[author creator fact_check_requestor] do
  end

  factory :vip_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::VIP_EDITOR] }

    trait(:with_preview_design_system) do
      permissions do
        [
          User::Permissions::SIGNIN,
          User::Permissions::VIP_EDITOR,
          User::Permissions::PREVIEW_DESIGN_SYSTEM,
        ]
      end
    end
  end

  factory :departmental_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::DEPARTMENTAL_EDITOR] }

    trait(:with_preview_design_system) do
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

  factory :managing_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::MANAGING_EDITOR] }

    trait(:with_preview_design_system) do
      permissions do
        [
          User::Permissions::SIGNIN,
          User::Permissions::MANAGING_EDITOR,
          User::Permissions::PREVIEW_DESIGN_SYSTEM,
        ]
      end
    end
  end

  factory :scheduled_publishing_robot, parent: :user do
    uid { nil }
    name { "Scheduled Publishing Robot" }
    permissions { [User::Permissions::SIGNIN, User::Permissions::PUBLISH_SCHEDULED_EDITIONS] }
  end

  factory :gds_admin, parent: :user do
    permissions do
      [
        User::Permissions::SIGNIN,
        User::Permissions::GDS_EDITOR,
        User::Permissions::GDS_ADMIN,
      ]
    end

    trait(:with_preview_design_system) do
      permissions do
        [
          User::Permissions::SIGNIN,
          User::Permissions::GDS_EDITOR,
          User::Permissions::GDS_ADMIN,
          User::Permissions::PREVIEW_DESIGN_SYSTEM,
        ]
      end
    end
  end

  factory :gds_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::GDS_EDITOR] }

    trait(:with_preview_design_system) do
      permissions do
        [
          User::Permissions::SIGNIN,
          User::Permissions::GDS_EDITOR,
          User::Permissions::PREVIEW_DESIGN_SYSTEM,
        ]
      end
    end
  end

  factory :world_editor, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::WORLD_EDITOR] }

    trait(:with_preview_design_system) do
      permissions do
        [
          User::Permissions::SIGNIN,
          User::Permissions::WORLD_EDITOR,
          User::Permissions::PREVIEW_DESIGN_SYSTEM,
        ]
      end
    end
  end

  factory :world_writer, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::WORLD_WRITER] }

    trait(:with_preview_design_system) do
      permissions do
        [
          User::Permissions::SIGNIN,
          User::Permissions::WORLD_WRITER,
          User::Permissions::PREVIEW_DESIGN_SYSTEM,
        ]
      end
    end
  end

  factory :export_data_user, parent: :user do
    permissions { [User::Permissions::SIGNIN, User::Permissions::EXPORT_DATA] }

    trait(:with_preview_design_system) do
      permissions do
        [
          User::Permissions::SIGNIN,
          User::Permissions::EXPORT_DATA,
          User::Permissions::PREVIEW_DESIGN_SYSTEM,
        ]
      end
    end
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

    trait(:with_preview_design_system) do
      permissions do
        [
          User::Permissions::SIGNIN,
          User::Permissions::DEPARTMENTAL_EDITOR,
          User::Permissions::GDS_EDITOR,
          User::Permissions::FORCE_PUBLISH_ANYTHING,
          User::Permissions::PREVIEW_DESIGN_SYSTEM,
        ]
      end
    end
  end
end

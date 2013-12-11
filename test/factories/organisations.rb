FactoryGirl.define do
  factory :organisation, traits: [:translated] do
    sequence(:name) { |index| "organisation-#{index}" }
    sequence(:logo_formatted_name) { |index| "organisation-#{index} logo text".split(" ").join("\n") }
    organisation_type_key :other
    sequence(:analytics_identifier) { |index| "T#{index}" }
    organisation_logo_type_id { OrganisationLogoType::SingleIdentity.id }

    trait(:closed) { govuk_status 'closed' }

    trait(:with_published_edition) {
      after :create do |organisation, evaluator|
        FactoryGirl.create(:published_publication, lead_organisations: [organisation])
      end
    }

    trait(:with_alternative_format_contact_email) {
      sequence(:alternative_format_contact_email) { |n| "organisation-#{n}@example.com" }
    }
  end

  factory :ministerial_department, parent: :organisation do
    organisation_type_key :ministerial_department
  end

  factory :organisation_with_alternative_format_contact_email, parent: :organisation, aliases: [:alternative_format_provider] do
    alternative_format_contact_email "alternative@example.com"
  end

  factory :sub_organisation, parent: :organisation do
    parent_organisations { [build(:organisation)] }
    organisation_type_key :sub_organisation
  end

  factory :executive_office, parent: :organisation do
    organisation_type_key :executive_office
  end

  factory :devolved_administration, parent: :organisation do
    organisation_type_key :devolved_administration
    govuk_status 'exempt'
  end
end

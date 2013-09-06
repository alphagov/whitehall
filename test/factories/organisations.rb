FactoryGirl.define do
  factory :organisation, traits: [:translated] do
    sequence(:name) { |index| "organisation-#{index}" }
    sequence(:logo_formatted_name) { |index| "organisation-#{index} logo text".split(" ").join("\n") }
    organisation_type_key :other
    analytics_identifier "T123"
    organisation_logo_type_id { OrganisationLogoType::SingleIdentity.id }
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
end

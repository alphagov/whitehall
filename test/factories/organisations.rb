FactoryGirl.define do
  factory :organisation, traits: [:translated] do
    sequence(:name) { |index| "organisation-#{index}" }
    sequence(:logo_formatted_name) { |index| "organisation-#{index} logo text".split(" ").join("\n") }
    organisation_type_id 123
    organisation_type

    analytics_identifier "T123"

    organisation_logo_type_id { OrganisationLogoType::SingleIdentity.id }
  end

  factory :ministerial_department, parent: :organisation do
    organisation_type {
      OrganisationType.find_by_name(build(:ministerial_organisation_type).name) || FactoryGirl.create(:ministerial_organisation_type)
    }
  end

  factory :organisation_with_alternative_format_contact_email, parent: :organisation, aliases: [:alternative_format_provider] do
    alternative_format_contact_email "alternative@example.com"
  end

  factory :sub_organisation, parent: :organisation do
    parent_organisations { [build(:organisation)] }
    organisation_type {
      OrganisationType.find_by_name(build(:sub_organisation_type).name) || FactoryGirl.create(:sub_organisation_type)
    }
  end

  factory :executive_office, parent: :organisation do
    organisation_type {
      OrganisationType.find_by_name(build(:executive_office_organisation_type).name) || create(:executive_office_organisation_type)
    }
  end
end

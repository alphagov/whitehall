FactoryBot.define do
  factory :organisation, traits: [:translated] do
    sequence(:name) { |index| "organisation-#{index}" }
    logo_formatted_name { name.to_s.split.join("\n") }
    organisation_type_key { :other }
    sequence(:analytics_identifier) { |index| "T#{index}" }
    organisation_logo_type_id { OrganisationLogoType::SingleIdentity.id }

    trait(:closed) do
      govuk_status { 'closed' }
      govuk_closed_status { 'no_longer_exists' }
    end

    trait(:with_published_edition) {
      after :create do |organisation, _evaluator|
        FactoryBot.create(:published_publication, lead_organisations: [organisation])
      end
    }

    trait(:with_alternative_format_contact_email) {
      sequence(:alternative_format_contact_email) { |n| "organisation-#{n}@example.com" }
    }

    trait(:with_feature_list) do
      transient do
        feature_list_count { 1 }
      end

      after(:create) do |organisation, evaluator|
        create_list(:feature_list, evaluator.feature_list_count, featurable: organisation)
      end
    end

    trait(:political) do
      political { true }
    end

    trait(:non_political) do
      political { false }
    end
  end

  factory :closed_organisation, parent: :organisation, traits: [:closed]

  factory :ministerial_department, parent: :organisation do
    organisation_type_key { :ministerial_department }
  end

  factory :non_ministerial_department, parent: :organisation do
    organisation_type_key { :non_ministerial_department }
  end

  factory :organisation_with_alternative_format_contact_email, parent: :organisation, aliases: [:alternative_format_provider] do
    alternative_format_contact_email { "alternative@example.com" }
  end

  factory :organisation_with_feature_list, parent: :organisation, traits: [:with_feature_list]

  factory :sub_organisation, parent: :organisation do
    parent_organisations { [build(:organisation)] }
    organisation_type_key { :sub_organisation }
  end

  factory :executive_office, parent: :organisation do
    organisation_type_key { :executive_office }
  end

  factory :devolved_administration, parent: :organisation do
    organisation_type_key { :devolved_administration }
    govuk_status { 'exempt' }
  end

  factory :court, parent: :organisation do
    organisation_type_key { :court }
    organisation_logo_type_id { OrganisationLogoType::NoIdentity.id }
    logo_formatted_name { name }
    parent_organisations {
      [Organisation.find_by(slug: "hm-courts-and-tribunals-service") ||
        build(:organisation, slug: "hm-courts-and-tribunals-service", name: "HMCTS")]
    }
  end

  factory :hmcts_tribunal, parent: :organisation do
    organisation_type_key { :tribunal_ndpb }
    organisation_logo_type_id { OrganisationLogoType::NoIdentity.id }
    logo_formatted_name { name }
    parent_organisations {
      [Organisation.find_by(slug: "hm-courts-and-tribunals-service") ||
        build(:organisation, slug: "hm-courts-and-tribunals-service", name: "HMCTS")]
    }
  end
end

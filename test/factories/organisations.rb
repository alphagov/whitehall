FactoryGirl.define do
  factory :organisation do
    sequence(:name) { |index| "organisation-#{index}" }
    sequence(:logo_formatted_name) { |index| "organisation-#{index} logo text".split(" ").join("\n") }
    organisation_type
  end

  factory :ministerial_department, parent: :organisation do
    organisation_type factory: :ministerial_organisation_type
  end

  factory :organisation_with_alternative_format_contact_email, parent: :organisation, aliases: [:alternative_format_provider] do
    alternative_format_contact_email "alternative@example.com"
  end
end
FactoryBot.define do
  factory :worldwide_organisation_page do
    summary { "Some summary" }
    body { "Some body" }
    corporate_information_page_type_id { CorporateInformationPageType::PublicationScheme.id }

    edition factory: :editionable_worldwide_organisation
  end
end

FactoryBot.define do
  factory :worldwide_organisation_page do
    corporate_information_page_type_id { CorporateInformationPageType::Recruitment.id }
    summary { "Some summary" }
    body { "Some body" }
  end
end

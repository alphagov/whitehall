FactoryGirl.define do
  factory :corporate_information_page, class: CorporateInformationPage, parent: :edition, traits: [:translated] do
    corporate_information_page_type_id CorporateInformationPageType::PublicationScheme.id
    body "Some stuff"
    locale "en"
    association :organisation, factory: :organisation
  end

  trait :with_alternative_format_provider do
  end
end

FactoryGirl.define do
  factory :corporate_information_page, traits: [:translated] do
    type_id CorporateInformationPageType::PublicationScheme.id
    body "Some stuff"
    association :organisation, factory: :organisation
  end

  trait :with_alternative_format_provider do
  end
end

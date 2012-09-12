FactoryGirl.define do
  factory :corporate_information_page do
    type_id CorporateInformationPageType::PublicationScheme.id
    body "Some stuff"
    association :organisation
  end

  trait :with_alternative_format_provider do
  end
end
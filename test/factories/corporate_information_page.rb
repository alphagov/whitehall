FactoryGirl.define do
  factory :corporate_information_page do
    type CorporateInformationPageType::PublicationScheme
    body "Some stuff"
    association :organisation
  end
end
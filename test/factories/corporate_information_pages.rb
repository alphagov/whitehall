FactoryGirl.define do
  factory :corporate_information_page, class: CorporateInformationPage, parent: :edition, traits: [:translated] do
    corporate_information_page_type_id CorporateInformationPageType::PublicationScheme.id
    body "Some stuff"
    association :organisation, factory: :organisation
  end

  trait :with_alternative_format_provider do
  end

  factory :published_corporate_information_page, parent: :corporate_information_page, traits: [:published]

  factory :about_corporate_information_page, parent: :published_corporate_information_page do
    corporate_information_page_type_id CorporateInformationPageType::AboutUs.id
  end

  factory :complaints_procedure_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id(
      CorporateInformationPageType::ComplaintsProcedure.id,
    )
  end

  factory :our_energy_use_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id(
      CorporateInformationPageType::OurEnergyUse.id,
    )
  end

  factory :procurement_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id(
      CorporateInformationPageType::Procurement.id,
    )
  end

  factory :recruitment_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id(
      CorporateInformationPageType::Recruitment.id,
    )
  end

  factory :published_worldwide_organisation_corporate_information_page, parent: :corporate_information_page, traits: [:published] do
    organisation nil
    association :worldwide_organisation, factory: :worldwide_organisation
  end
end

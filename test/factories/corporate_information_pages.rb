FactoryBot.define do
  factory :corporate_information_page, class: CorporateInformationPage, parent: :edition, traits: [:translated] do
    corporate_information_page_type_id { CorporateInformationPageType::PublicationScheme.id }
    body { "Some stuff" }
    association :organisation, factory: :organisation

    after(:create) do |corporate_information_page, _evaluator|
      corporate_information_page.organisation
        .try(:corporate_information_pages).try(:reload)
    end
  end

  trait :with_alternative_format_provider do
  end

  factory :published_corporate_information_page, parent: :corporate_information_page, traits: [:published]
  factory :draft_corporate_information_page, parent: :corporate_information_page, traits: [:draft]

  factory :about_corporate_information_page, parent: :published_corporate_information_page do
    corporate_information_page_type_id { CorporateInformationPageType::AboutUs.id }
  end

  factory :draft_about_corporate_information_page, parent: :draft_corporate_information_page do
    corporate_information_page_type_id { CorporateInformationPageType::AboutUs.id }
  end

  factory :about_our_services_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id do
      CorporateInformationPageType::AboutOurServices.id
    end
  end

  factory :complaints_procedure_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id do
      CorporateInformationPageType::ComplaintsProcedure.id
    end
  end

  factory :our_energy_use_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id do
      CorporateInformationPageType::OurEnergyUse.id
    end
  end

  factory :personal_information_charter_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id do
      CorporateInformationPageType::PersonalInformationCharter.id
    end
  end

  factory :procurement_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id do
      CorporateInformationPageType::Procurement.id
    end
  end

  factory :publication_scheme_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id do
      CorporateInformationPageType::PublicationScheme.id
    end
  end

  factory :recruitment_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id do
      CorporateInformationPageType::Recruitment.id
    end
  end

  factory :social_media_use_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id do
      CorporateInformationPageType::SocialMediaUse.id
    end
  end

  factory :welsh_language_scheme_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id do
      CorporateInformationPageType::WelshLanguageScheme.id
    end
  end

  factory :accessible_documents_policy_corporate_information_page,
          parent: :published_corporate_information_page do
    corporate_information_page_type_id do
      CorporateInformationPageType::AccessibleDocumentsPolicy.id
    end
  end
end

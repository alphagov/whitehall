FactoryBot.define do
  factory :worldwide_organisation, class: WorldwideOrganisation, parent: :edition_with_organisations, traits: [:translated] do
    title { "Worldwide organisation title" }
    logo_formatted_name { title.to_s.split.join("\n") }
    summary { "Basic information about the organisation." }
    body { "Information about the organisation with _italics_." }

    after :build do |organisation, evaluator|
      if evaluator.world_locations.empty?
        organisation.world_locations << build(:world_location)
      end
    end

    trait(:with_role) do
      after :create do |organisation, _evaluator|
        organisation.roles << create(:ambassador_role)
      end
    end

    trait(:with_main_office) do
      after :create do |organisation, _evaluator|
        FactoryBot.create(:worldwide_office, edition: organisation)
      end
    end

    trait(:with_home_page_offices) do
      after :create do |organisation, _evaluator|
        worldwide_office = create(:worldwide_office, edition: organisation)
        organisation.add_office_to_home_page!(worldwide_office)
      end
    end

    trait(:with_social_media_account) do
      after :create do |organisation, _evaluator|
        create(:social_media_account, socialable: organisation, social_media_service: create(:social_media_service, name: "Blog"))
      end
    end

    trait(:with_default_news_image) do
      after :build do |organisation|
        organisation.default_news_image = build(:featured_image_data)
      end
    end

    trait(:with_page) do
      after :create do |organisation, _evaluator|
        organisation.pages = [build(:worldwide_organisation_page)]
      end
    end

    trait(:with_translated_page) do
      after :create do |organisation, _evaluator|
        organisation.pages = [build(:worldwide_organisation_page, translated_into: :fr)]
      end
    end

    trait(:with_pages) do
      after :create do |organisation, _evaluator|
        organisation.pages = [
          build(:worldwide_organisation_page, corporate_information_page_type: CorporateInformationPageType::ComplaintsProcedure, edition: organisation),
          build(:worldwide_organisation_page, corporate_information_page_type: CorporateInformationPageType::PersonalInformationCharter, edition: organisation),
          build(:worldwide_organisation_page, corporate_information_page_type: CorporateInformationPageType::PublicationScheme, edition: organisation),
          build(:worldwide_organisation_page, corporate_information_page_type: CorporateInformationPageType::Recruitment, edition: organisation),
          build(:worldwide_organisation_page, corporate_information_page_type: CorporateInformationPageType::WelshLanguageScheme, edition: organisation),
        ]
      end
    end
  end

  factory :draft_worldwide_organisation, parent: :worldwide_organisation, traits: [:draft]
  factory :submitted_worldwide_organisation, parent: :worldwide_organisation, traits: [:submitted]
  factory :rejected_worldwide_organisation, parent: :worldwide_organisation, traits: [:rejected]
  factory :published_worldwide_organisation, parent: :worldwide_organisation, traits: [:published]
  factory :deleted_worldwide_organisation, parent: :worldwide_organisation, traits: [:deleted]
  factory :superseded_worldwide_organisation, parent: :worldwide_organisation, traits: [:superseded]
  factory :scheduled_worldwide_organisation, parent: :worldwide_organisation, traits: [:scheduled]
  factory :unpublished_worldwide_organisation, parent: :worldwide_organisation, traits: [:unpublished]
  factory :unpublished_worldwide_organisation_consolidated, parent: :worldwide_organisation, traits: [:consolidated_redirect]
  factory :unpublished_worldwide_organisation_in_error_redirect, parent: :worldwide_organisation, traits: [:published_in_error_redirect]
  factory :unpublished_worldwide_organisation_in_error_no_redirect, parent: :worldwide_organisation, traits: [:published_in_error_no_redirect]
  factory :withdrawn_worldwide_organisation, parent: :worldwide_organisation, traits: [:withdrawn]
end

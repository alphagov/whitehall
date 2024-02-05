FactoryBot.define do
  factory :editionable_worldwide_organisation, class: EditionableWorldwideOrganisation, parent: :edition_with_organisations, traits: [:translated] do
    title { "Editionable worldwide organisation title" }
    logo_formatted_name { title.to_s.split.join("\n") }
    summary { "Basic information about the organisation." }
    body { "Information about the organisation with _italics_." }

    after :build do |news_article, evaluator|
      if evaluator.world_locations.empty?
        news_article.world_locations << build(:world_location)
      end
    end

    trait(:with_role) do
      after :create do |organisation, _evaluator|
        organisation.roles << create(:ambassador_role)
      end
    end

    trait(:with_office) do
      after :create do |organisation, _evaluator|
        FactoryBot.create(:worldwide_office, worldwide_organisation: nil, edition: organisation)
      end
    end

    trait(:with_social_media_account) do
      after :create do |organisation, _evaluator|
        create(:social_media_account, socialable: organisation, social_media_service: create(:social_media_service, name: "Blog"))
      end
    end
  end

  factory :draft_editionable_worldwide_organisation, parent: :editionable_worldwide_organisation, traits: [:draft]
end

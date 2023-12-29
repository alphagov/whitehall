FactoryBot.define do
  factory :editionable_worldwide_organisation, class: EditionableWorldwideOrganisation, parent: :edition_with_organisations do
    title { "Editionable worldwide organisation title" }
    logo_formatted_name { title.to_s.split.join("\n") }

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
  end

  factory :draft_editionable_worldwide_organisation, parent: :editionable_worldwide_organisation, traits: [:draft]
end

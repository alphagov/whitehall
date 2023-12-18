FactoryBot.define do
  factory :editionable_worldwide_organisation, class: EditionableWorldwideOrganisation, parent: :edition_with_organisations do
    title { "editionable-worldwide-organisation-title" }

    after :build do |news_article, evaluator|
      if evaluator.world_locations.empty?
        news_article.world_locations << build(:world_location)
      end
    end
  end

  factory :draft_editionable_worldwide_organisation, parent: :editionable_worldwide_organisation, traits: [:draft]
end

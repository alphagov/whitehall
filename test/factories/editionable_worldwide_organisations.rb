FactoryBot.define do
  factory :editionable_worldwide_organisation, class: EditionableWorldwideOrganisation, parent: :edition_with_organisations do
    title { "editionable-worldwide-organisation-title" }
  end

  factory :draft_editionable_worldwide_organisation, parent: :editionable_worldwide_organisation, traits: [:draft]
end

FactoryBot.define do
  factory :editionable_topical_event, class: EditionableTopicalEvent, parent: :edition do
    title { "editionable-topical-event-title" }
    summary { "Some basic info about the event" }
  end

  factory :draft_editionable_topical_event, parent: :editionable_topical_event, traits: [:draft]
end

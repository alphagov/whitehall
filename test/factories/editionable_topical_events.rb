FactoryBot.define do
  factory :editionable_topical_event, class: EditionableTopicalEvent, parent: :edition do
    title { "editionable-topical-event-title" }
    summary { "Some basic info about the event" }
  end

  factory :draft_editionable_topical_event, parent: :editionable_topical_event, traits: [:draft]

  trait(:with_social_media_account) do
    after :create do |organisation, _evaluator|
      create(:social_media_account, socialable: organisation, social_media_service: create(:social_media_service, name: "Blog"))
    end
  end
end

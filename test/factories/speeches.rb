FactoryBot.define do
  factory :speech, class: Speech, parent: :edition, traits: %i[with_organisations] do
    title { "speech-title" }
    body  { "speech-body" }
    association :role_appointment, factory: :ministerial_role_appointment
    delivered_on { Time.zone.now }
    location { "speech-location" }
    speech_type { SpeechType::Transcript }
  end

  factory :draft_speech, parent: :speech, traits: [:draft]
  factory :submitted_speech, parent: :speech, traits: [:submitted]
  factory :rejected_speech, parent: :speech, traits: [:rejected]
  factory :published_speech, parent: :speech, traits: [:published] do
    first_published_at { 2.days.ago }
  end
  factory :deleted_speech, parent: :speech, traits: [:deleted]
  factory :superseded_speech, parent: :speech, traits: [:superseded]
  factory :scheduled_speech, parent: :speech, traits: [:scheduled]
end

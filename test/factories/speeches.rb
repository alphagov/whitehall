FactoryGirl.define do
  factory :speech, class: Speech, parent: :document do
    title "speech-title"
    body  "speech-body"
    association :role_appointment, factory: :ministerial_role_appointment
    delivered_on { Date.today }
    location "speech-location"
    speech_type
  end

  factory :draft_speech, parent: :speech, traits: [:draft]
  factory :submitted_speech, parent: :speech, traits: [:submitted]
  factory :rejected_speech, parent: :speech, traits: [:rejected]
  factory :published_speech, parent: :speech, traits: [:published]
  factory :deleted_speech, parent: :speech, traits: [:deleted]
  factory :archived_speech, parent: :speech, traits: [:archived]
end
FactoryGirl.define do
  factory :speech, class: Speech, parent: :edition_with_organisations do
    title "speech-title"
    body  "speech-body"
    association :role_appointment, factory: :ministerial_role_appointment
    delivered_on { Time.zone.now }
    location "speech-location"
    speech_type SpeechType::Transcript
    ignore do
      relevant_to_local_government { false }
    end

    after(:build) do |object, evaluator|
      if evaluator.relevant_to_local_government
        object.related_policy_ids = [FactoryGirl.create(:published_policy, relevant_to_local_government: true)].map(&:id)
      end
    end
  end

  factory :imported_speech, parent: :speech, traits: [:imported]
  factory :draft_speech, parent: :speech, traits: [:draft]
  factory :submitted_speech, parent: :speech, traits: [:submitted]
  factory :rejected_speech, parent: :speech, traits: [:rejected]
  factory :published_speech, parent: :speech, traits: [:published] do
    first_published_at  { 2.days.ago }
  end
  factory :deleted_speech, parent: :speech, traits: [:deleted]
  factory :superseded_speech, parent: :speech, traits: [:superseded]
  factory :scheduled_speech, parent: :speech, traits: [:scheduled]
end

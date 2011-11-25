FactoryGirl.define do
  factory :speech, class: Speech, parent: :document do
    title "speech-title"
    body  "speech-body"
    association :role_appointment, factory: :ministerial_role_appointment
    delivered_on { Date.today }
    location "speech-location"
  end

  factory :draft_speech, parent: :speech, traits: [:draft]
  factory :submitted_speech, parent: :speech, traits: [:submitted]
  factory :rejected_speech, parent: :speech, traits: [:rejected]
  factory :published_speech, parent: :speech, traits: [:published]
  factory :deleted_speech, parent: :speech, traits: [:deleted]
  factory :archived_speech, parent: :speech, traits: [:archived]

  factory :speech_transcript, class: Speech::Transcript, parent: :speech
  factory :speech_draft_text, class: Speech::DraftText, parent: :speech
  factory :speech_speaking_notes, class: Speech::SpeakingNotes, parent: :speech
  factory :speech_written_statement, class: Speech::WrittenStatement, parent: :speech
  factory :speech_oral_statement, class: Speech::OralStatement, parent: :speech

  factory :draft_speech_transcript, parent: :speech_transcript, traits: [:draft]
  factory :published_speech_transcript, parent: :speech_transcript, traits: [:published]
end
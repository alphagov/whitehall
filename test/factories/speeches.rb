FactoryGirl.define do
  factory :speech, class: Speech::Transcript do
    author
    title "speech-title"
    body  "speech-body"
    role_appointment
    delivered_on { Date.today }
    location "speech-location"
  end

  factory :draft_speech, parent: :speech do
    state "draft"
  end

  factory :submitted_speech, parent: :speech do
    state "submitted"
  end

  factory :rejected_speech, parent: :speech do
    state "rejected"
  end

  factory :published_speech, parent: :speech do
    state "published"
  end

  factory :archived_speech, parent: :speech do
    state "archived"
  end

  factory :speech_transcript, class: Speech::Transcript, parent: :speech do
  end

  factory :speech_draft_text, class: Speech::DraftText, parent: :speech do
  end

  factory :speech_speaking_notes, class: Speech::SpeakingNotes, parent: :speech do
  end

  factory :speech_written_statement, class: Speech::WrittenStatement, parent: :speech do
  end

  factory :speech_oral_statement, class: Speech::OralStatement, parent: :speech do
  end
end
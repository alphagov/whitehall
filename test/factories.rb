FactoryGirl.define do
  factory :document_identity do
  end

  factory :document do
    author
    title "document-title"
    body "document-body"
  end

  factory :policy do
    author
    title "policy-title"
    body  "policy-body"
  end

  factory :publication do
    author
    title "publication-title"
    body  "publication-body"
  end

  factory :news_article do
    author
    title "news-title"
    body  "news-body"
  end

  factory :speech, class: Speech::Transcript do
    author
    title "speech-title"
    body  "speech-body"
    role_appointment
    delivered_on Date.today
    location "speech-location"
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

  factory :consultation do
    author
    title "consultation-title"
    body  "consultation-body"
    opening_on 1.day.ago
    closing_on 6.weeks.from_now
  end

  factory :published_policy, parent: :policy do
    state "published"
    submitted true
  end

  factory :draft_policy, parent: :policy do
    state "draft"
  end

  factory :deleted_policy, parent: :policy do
    state "deleted"
  end

  factory :archived_policy, parent: :policy do
    state "archived"
    submitted true
  end

  factory :submitted_policy, parent: :policy do
    state "draft"
    submitted true
  end

  factory :published_publication, parent: :publication do
    state "published"
    submitted true
  end

  factory :draft_publication, parent: :publication do
    state "draft"
  end

  factory :archived_publication, parent: :publication do
    state "archived"
    submitted true
  end

  factory :submitted_publication, parent: :publication do
    state "draft"
    submitted true
  end

  factory :draft_news_article, parent: :news_article do
    state "draft"
  end

  factory :submitted_news_article, parent: :news_article do
    state "draft"
    submitted true
  end

  factory :published_news_article, parent: :news_article do
    state "published"
    submitted true
  end

  factory :archived_news_article, parent: :news_article do
    state "archived"
    submitted true
  end

  factory :draft_consultation, parent: :consultation do
    state "draft"
  end

  factory :submitted_consultation, parent: :consultation do
    state "draft"
    submitted true
  end

  factory :published_consultation, parent: :consultation do
    state "published"
    submitted true
  end

  factory :archived_consultation, parent: :consultation do
    state "archived"
    submitted true
  end

  factory :draft_speech, parent: :speech do
    state "draft"
  end

  factory :submitted_speech, parent: :speech do
    state "draft"
    submitted true
  end

  factory :published_speech, parent: :speech do
    state "published"
    submitted true
  end

  factory :archived_speech, parent: :speech do
    state "archived"
    submitted true
  end

  factory :fact_check_request do
    association :document, factory: :policy
    email_address "fact-checker@example.com"
  end

  factory :user do
    name "Daaaaaaave"
  end

  factory :policy_writer, parent: :user, aliases: [:author] do
    departmental_editor false
  end

  factory :departmental_editor, parent: :user do
    departmental_editor true
  end

  factory :attachment do
    file { File.open(File.join(Rails.root, 'test', 'fixtures', 'greenpaper.pdf')) }
  end

  factory :document_attachment do
    association :document, factory: :publication
    attachment
  end

  factory :topic do
    sequence(:name) { |index| "topic-#{index}" }
    description { Faker::Lorem.sentence }
  end

  factory :organisation do
    sequence(:name) { |index| "organisation-#{index}" }
  end

  factory :ministerial_role, aliases: [:role] do
    name "Parliamentary Under-Secretary of State"
  end

  factory :board_member_role do
    name "Permanent Secretary"
  end

  factory :role_appointment do
    role
    person
    started_at 1.day.ago
  end

  factory :person do
    name "George"
  end

  factory :supporting_document do
    title "Something Supportive"
    body "Some supporting information"
    association :document, factory: :policy
  end

  factory :nation_inapplicability do
  end
end
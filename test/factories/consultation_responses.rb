FactoryGirl.define do
  factory :consultation_response, class: ConsultationResponse, parent: :edition do
    title "response-title"
    association :consultation, factory: :published_consultation
  end

  factory :draft_consultation_response, parent: :consultation_response, traits: [:draft]
  factory :submitted_consultation_response, parent: :consultation_response, traits: [:submitted]
  factory :rejected_consultation_response, parent: :consultation_response, traits: [:rejected]
  factory :published_consultation_response, parent: :consultation_response, traits: [:published]
  factory :deleted_consultation_response, parent: :consultation_response, traits: [:deleted]
  factory :archived_consultation_response, parent: :consultation_response, traits: [:archived]
end
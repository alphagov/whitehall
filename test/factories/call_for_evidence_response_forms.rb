FactoryBot.define do
  factory :call_for_evidence_response_form do
    transient do
      file { File.open(Rails.root.join("test/fixtures/two-pages.pdf")) }
    end
    association :call_for_evidence_participation
    title { "call-for-evidence-response-form-title" }
    call_for_evidence_response_form_data { build(:call_for_evidence_response_form_data, file:) }
  end
end

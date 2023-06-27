FactoryBot.define do
  trait :call_for_evidence_response do
    call_for_evidence
    published_on { Time.zone.today }
  end

  factory :call_for_evidence_outcome, traits: [:call_for_evidence_response] do
    sequence :summary do |n|
      "outcome summary #{n}"
    end

    trait(:with_file_attachment) do
      attachments { [FactoryBot.build(:file_attachment)] }
    end

    trait(:with_html_attachment) do
      attachments { [FactoryBot.build(:html_attachment)] }
    end
  end
end

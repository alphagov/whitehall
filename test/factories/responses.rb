FactoryBot.define do
  trait :response do
    consultation
    published_on { Time.zone.today }
  end

  factory :consultation_outcome, traits: [:response] do
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

  factory :consultation_public_feedback, traits: [:response] do
    sequence :summary do |n|
      "public feedback summary #{n}"
    end

    trait(:with_file_attachment) do
      attachments { [FactoryBot.build(:file_attachment)] }
    end

    trait(:with_html_attachment) do
      attachments { [FactoryBot.build(:html_attachment)] }
    end
  end
end

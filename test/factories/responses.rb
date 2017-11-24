FactoryBot.define do
  trait :response do
    consultation
    published_on { Date.today }
  end

  factory :consultation_outcome, traits: [:response] do
    sequence :summary do |n|
      "outcome summary #{n}"
    end

    trait(:with_file_attachment) do
      attachments { FactoryBot.build_list :file_attachment, 1 }

      after :create do |consultation_outcome, _|
        VirusScanHelpers.simulate_virus_scan(
          consultation_outcome.attachments.first.attachment_data.file
        )
      end
    end
  end

  factory :consultation_public_feedback, traits: [:response] do
    sequence :summary do |n|
      "public feedback summary #{n}"
    end

    trait(:with_file_attachment) do
      attachments { FactoryBot.build_list :file_attachment, 1 }

      after :create do |consultation_outcome, _|
        VirusScanHelpers.simulate_virus_scan(
          consultation_outcome.attachments.first.attachment_data.file
        )
      end
    end
  end
end

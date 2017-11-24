FactoryBot.define do
  factory :policy_group do
    sequence(:email) { |n| "policy-group-#{n}@example.com" }
    name 'policy-group-name'
    description ''

    trait(:with_file_attachment) do
      attachments { FactoryBot.build_list :file_attachment, 1 }
      after :create do |edition, _evaluator|
        VirusScanHelpers.simulate_virus_scan(edition.attachments.first.attachment_data.file)
      end
    end
  end
end

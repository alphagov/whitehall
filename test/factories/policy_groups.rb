FactoryBot.define do
  factory :policy_group do
    sequence(:email) { |n| "policy-group-#{n}@example.com" }
    name 'policy-group-name'
    description ''

    trait(:with_file_attachment) do
      attachments { FactoryBot.build_list :file_attachment, 1 }
    end
  end
end

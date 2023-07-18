FactoryBot.define do
  factory :review_reminder do
    creator
    document

    sequence :email_address do |n|
      "creator-#{n}@example.com"
    end

    review_at { Time.zone.now + 1.day }

    trait(:with_reminder_sent_at) do
      reminder_sent_at { 1.day.ago }
    end
  end
end

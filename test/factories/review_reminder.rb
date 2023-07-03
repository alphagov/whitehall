FactoryBot.define do
  factory :review_reminder do
    creator
    document

    sequence :email_address do |n|
      "creator-#{n}@example.com"
    end

    review_at { Time.zone.now + 1.day }
  end
end

FactoryGirl.define do
  factory :statistics_announcement do
    sequence(:title) { |index| "Stats announcement #{index}" }
    summary "Summary of announcement"
    publication_type_id PublicationType::Statistics.id

    association :statistics_announcement_date
    association :organisation
    association :topic
    association :creator, factory: :policy_writer
  end
end

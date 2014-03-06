FactoryGirl.define do
  factory :statistical_release_announcement do
    sequence(:title) { |index| "Stats announcement #{index}" }
    summary "Summary of announcement"
    publication_type_id PublicationType::Statistics.id
    expected_release_date 1.year.from_now

    association :organisation
    association :topic
    association :creator, factory: :policy_writer
  end
end

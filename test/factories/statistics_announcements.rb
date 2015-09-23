FactoryGirl.define do
  factory :statistics_announcement do
    transient do
      release_date nil
    end

    sequence(:title) { |index| "Stats announcement #{index}" }
    summary "Summary of announcement"
    publication_type_id PublicationType::OfficialStatistics.id
    organisations { FactoryGirl.build_list :organisation, 1 }

    topics { FactoryGirl.build_list :topic, 1 }
    association :creator, factory: :writer
    association :current_release_date, factory: :statistics_announcement_date

    after :build do |announcement, evaluator|
      if evaluator.release_date.present?
        announcement.current_release_date.release_date = evaluator.release_date
      end
    end
  end

  factory :cancelled_statistics_announcement, parent: :statistics_announcement do
    cancellation_reason "Cancelled for a reason"
    cancelled_at Time.zone.now
  end

  factory :unpublished_statistics_announcement, parent: :statistics_announcement do
    publishing_state "unpublished"
    redirect_url "https://www.test.alphagov.co.uk/government/sparkle"
  end
end

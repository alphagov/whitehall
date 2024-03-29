FactoryBot.define do
  factory :statistics_announcement do
    transient do
      release_date { nil }
      previous_display_date { nil }
      change_note { nil }
    end

    sequence(:title) { |index| "Stats announcement #{index}" }
    summary { "Summary of announcement" }
    publication_type_id { PublicationType::OfficialStatistics.id }
    organisations { FactoryBot.build_list :organisation, 1 }

    association :creator, factory: :writer
    statistics_announcement_dates { build_list(:statistics_announcement_date, 1) }

    after :build do |announcement, evaluator|
      if evaluator.release_date.present?
        announcement.statistics_announcement_dates.last.release_date = evaluator.release_date
      end

      if evaluator.change_note.present?
        announcement.statistics_announcement_dates.last.change_note = evaluator.change_note
      end

      if evaluator.previous_display_date.present?
        announcement.statistics_announcement_dates.first.save!
        announcement.statistics_announcement_dates <<
          create(
            :statistics_announcement_date_change,
            current_release_date: announcement.statistics_announcement_dates.last,
            release_date: evaluator.previous_display_date,
          )
      end
    end
  end

  factory :cancelled_statistics_announcement, parent: :statistics_announcement do
    cancellation_reason { "Cancelled for a reason" }
    cancelled_at { Time.zone.now }
  end

  factory :unpublished_statistics_announcement, parent: :statistics_announcement do
    publishing_state { "unpublished" }
    redirect_url { "https://www.test.gov.uk/government/sparkle" }
  end

  factory :statistics_announcement_requiring_redirect,
          parent: :unpublished_statistics_announcement do
  end
end

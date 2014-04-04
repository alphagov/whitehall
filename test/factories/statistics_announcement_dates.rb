FactoryGirl.define do
  factory :statistics_announcement_date do
    release_date { Time.zone.today + 1.month + 9.hours + 30.minutes }
    precision    StatisticsAnnouncementDate::PRECISION[:one_month]
    confirmed    false
  end

  factory :statistics_announcement_date_change do
    release_date { Time.zone.today + 1.month + 9.hours + 30.minutes }
    current_release_date { create(:statistics_announcement_date) }
    precision    StatisticsAnnouncementDate::PRECISION[:exact]
    confirmed    true
  end
end

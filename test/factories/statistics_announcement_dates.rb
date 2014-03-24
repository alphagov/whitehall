FactoryGirl.define do
  factory :statistics_announcement_date do
    release_date { 1.year.from_now }
    precision    StatisticsAnnouncementDate::PRECISION[:one_month]
    confirmed    false
  end

  factory :statistics_announcement_date_change do
    release_date { 1.year.from_now }
    current_release_date { create(:statistics_announcement_date) }
    precision    StatisticsAnnouncementDate::PRECISION[:exact]
    confirmed    true
  end
end

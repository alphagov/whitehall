FactoryGirl.define do
  factory :statistics_announcement_date do
    release_date { 1.year.from_now }
    precision    StatisticsAnnouncementDate::PRECISION[:exact]
    confirmed    true
  end
end

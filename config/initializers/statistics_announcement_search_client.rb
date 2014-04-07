Whitehall.statistics_announcement_search_client = if Rails.env.test? || (Rails.env.development? && ENV['RUMMAGER_HOST'].nil?)
  DevelopmentModeStubs::FakeRummagerApiForStatisticsAnnouncements
else
  GdsApi::Rummager.new(Whitehall::SearchIndex.rummager_host + Whitehall.government_search_index_path)
end

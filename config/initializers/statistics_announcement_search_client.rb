Whitehall.statistics_announcement_search_client = if Rails.env.test?
  DevelopmentModeStubs::FakeRummagerApiForStatisticsAnnouncements
else
  GdsApi::Rummager.new(Whitehall::SearchIndex.rummager_host + Whitehall.government_search_index_path)
end

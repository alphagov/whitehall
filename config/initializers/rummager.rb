require 'gds_api/rummager'

Whitehall.government_search_client = GdsApi::Rummager.new(
  Plek.find('rummager') + Whitehall::SearchIndex.government_search_index_path
)

Whitehall.search_client = GdsApi::Rummager.new(
  Plek.find('rummager')
)

def statistics_announcement_search_client
  if Rails.env.test?
    DevelopmentModeStubs::FakeRummagerApiForStatisticsAnnouncements
  else
    GdsApi::Rummager.new(
      Plek.find('rummager') + Whitehall::SearchIndex.government_search_index_path
    )
  end
end

Whitehall.statistics_announcement_search_client = statistics_announcement_search_client

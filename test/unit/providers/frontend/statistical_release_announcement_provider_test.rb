class Frontend::StatisticalReleaseAnnouncementProviderTest < ActiveSupport::TestCase
  attr_accessor :rummager_api_stub

  setup do
    @mock_source ||= mock
    Frontend::StatisticalReleaseAnnouncementProvider.stubs(:source).returns(@mock_source)
  end

  test ".find_by should ask rummager for all release announcements which match the filter params given" do
    @mock_source.stubs(:find_by).with({keyword: 'keyword'}).returns([:an_announcement_hash, :another_announcement_hash])
    Frontend::StatisticalReleaseAnnouncement.stubs(:new).with(:an_announcement_hash).returns(:an_announcement)
    Frontend::StatisticalReleaseAnnouncement.stubs(:new).with(:another_announcement_hash).returns(:another_announcement)

    assert_equal [:an_announcement, :another_announcement], Frontend::StatisticalReleaseAnnouncementProvider.find_by(keyword: 'keyword')
  end
end

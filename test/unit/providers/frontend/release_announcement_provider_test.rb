class Frontend::ReleaseAnnouncementProviderTest < ActiveSupport::TestCase
  attr_accessor :rummager_api_stub

  setup do
    @rummager_api_stub ||= mock
    Frontend::ReleaseAnnouncementProvider.stubs(:rummager_api).returns(@rummager_api_stub)
  end

  test ".find_by should ask rummager for all release announcements which match the filter params given" do
    rummager_api_stub.stubs(:release_announcements).with({keyword: 'keyword'}).returns([:an_announcement_hash, :another_announcement_hash])
    Frontend::ReleaseAnnouncement.stubs(:new).with(:an_announcement_hash).returns(:an_announcement)
    Frontend::ReleaseAnnouncement.stubs(:new).with(:another_announcement_hash).returns(:another_announcement)

    assert_equal [:an_announcement, :another_announcement], Frontend::ReleaseAnnouncementProvider.find_by(keyword: 'keyword')
  end
end

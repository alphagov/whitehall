class Frontend::ReleaseAnnouncementProviderTest < ActiveSupport::TestCase
  attr_accessor :rummager_api_stub

  setup do
    @rummager_api_stub ||= mock
    Frontend::ReleaseAnnouncementProvider.stubs(:rummager_api).returns(@rummager_api_stub)
  end

  test ".all should ask rummager for all release_announcements, and should return them in a collection of inflated ReleaseAnnouncements" do
    rummager_api_stub.stubs(:release_announcements).with().returns([:an_announcement_hash, :another_announcement_hash])
    Frontend::ReleaseAnnouncement.stubs(:new).with(:an_announcement_hash).returns(:an_announcement)
    Frontend::ReleaseAnnouncement.stubs(:new).with(:another_announcement_hash).returns(:another_announcement)

    assert_equal [:an_announcement, :another_announcement], Frontend::ReleaseAnnouncementProvider.all
  end
end

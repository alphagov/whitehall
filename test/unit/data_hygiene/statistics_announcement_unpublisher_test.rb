require 'test_helper'
require 'gds_api/test_helpers/router'

module DataHygiene
  class StatisticsAnnouncementUnpublisherTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Router

    setup do
      @fake_logger = NullLogger.instance
      @announcement = create(:statistics_announcement)
    end

    test "reports an error when given a non-existent slug" do
      unpublisher = StatisticsAnnouncementUnpublisher.new(
        announcement_slug: "not-a-real-slug",
        logger: @fake_logger,
      )

      @fake_logger.expects(:error).once.with(regexp_matches(/not-a-real-slug/))

      unpublisher.call
    end

    test "destroys the announcement and registers a 'Gone' route when given a valid slug" do
      unpublisher = StatisticsAnnouncementUnpublisher.new(
        announcement_slug: @announcement.slug,
        logger: @fake_logger,
      )

      register_request, commit_request = stub_gone_route_registration(@announcement.public_path, :exact)

      unpublisher.call

      refute StatisticsAnnouncement.exists?(@announcement.id)

      assert_requested(register_request)
      assert_requested(commit_request)
    end
  end
end

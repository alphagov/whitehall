require 'test_helper'
require 'gds_api/test_helpers/router'

module DataHygiene
  class DuplicateStatisticsAnnouncementTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Router

    test "#destroy_and_redirect_to registers a redirect and destroys the announcement" do
      announcement = create(:statistics_announcement)
      duplicate    = create(:statistics_announcement, title: announcement.title, organisation_ids: [announcement.organisations.first.id])

      announcement_path = Whitehall.url_maker.statistics_announcement_path(announcement)
      duplicate_path    = Whitehall.url_maker.statistics_announcement_path(duplicate)

      registration_request, commit_request = stub_redirect_registration(duplicate_path, :exact, announcement_path, "permanent")

      DuplicateStatisticsAnnouncement.new(duplicate).destroy_and_redirect_to(announcement)

      assert_requested(registration_request)
      assert_requested(commit_request)

      refute StatisticsAnnouncement.exists?(duplicate.id)
      assert StatisticsAnnouncement.exists?(announcement.id)
    end
  end
end

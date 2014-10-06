require 'test_helper'

class Admin::StatisticsAnnouncementFilterTest < ActiveSupport::TestCase
  test "can filter by title" do
    match    = create(:statistics_announcement, title: "MQ5 statistics")
    no_match = create(:statistics_announcement, title: "PQ5 statistics")
    filter   = Admin::StatisticsAnnouncementFilter.new(title: "mq5")

    assert_equal [match], filter.statistics_announcements
  end

  test "can filter by organisation" do
    organisation = create(:organisation)
    match        = create(:statistics_announcement, organisation_ids: [organisation.id])
    no_match     = create(:statistics_announcement)
    filter       = Admin::StatisticsAnnouncementFilter.new(organisation_id: organisation.id)

    assert_equal [match], filter.statistics_announcements
  end
end

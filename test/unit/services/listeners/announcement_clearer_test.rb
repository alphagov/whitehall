require 'test_helper'

class AnnouncementClearerTest < ActiveSupport::TestCase
  test '#clear! any associated announcement from the search index' do
    announcement = create(:statistics_announcement)
    statistics = create(:published_statistics,
      statistics_announcement: announcement)

    Whitehall::SearchIndex.expects(:delete).with(announcement)
    ServiceListeners::AnnouncementClearer.new(statistics).clear!
  end

  test '#clear! does not raise an error if the edition does not have an announcement' do
    statistics = create(:published_statistics)
    ServiceListeners::AnnouncementClearer.new(statistics).clear!
  end

  test '#clear! does not raise an error if the edition is not a statistial publication' do
    statistics = create(:published_case_study)
    ServiceListeners::AnnouncementClearer.new(statistics).clear!
  end
end

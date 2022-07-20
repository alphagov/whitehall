require "test_helper"

class TopicalEventAboutPageTest < ActiveSupport::TestCase
  test "should return search index data suitable for Rummageable" do
    event = create(:topical_event)
    page = create(:topical_event_about_page, topical_event: event)
    assert_equal page.name, page.search_index["title"]
    assert_equal "/government/topical-events/#{event.slug}/about", page.search_index["link"]
  end

  should_not_accept_footnotes_in :body
end

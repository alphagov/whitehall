require "test_helper"

class TopicalEventAboutPageTest < ActiveSupport::TestCase
  test "should return search index data suitable for Rummageable" do
    event = create(:topical_event)
    page = create(:topical_event_about_page, topical_event: event)
    assert_equal page.name, page.search_index["title"]
    assert_equal "/government/topical-events/#{event.slug}/about", page.search_index["link"]
  end

  test "public_path returns the correct path" do
    object = create(:topical_event, slug: "foo", topical_event_about_page: create(:topical_event_about_page))
    assert_equal "/government/topical-events/foo/about", object.topical_event_about_page.public_path
  end

  test "public_path returns the correct path with options" do
    object = create(:topical_event, slug: "foo", topical_event_about_page: create(:topical_event_about_page))
    assert_equal "/government/topical-events/foo/about?cachebust=123", object.topical_event_about_page.public_path(cachebust: "123")
  end

  test "public_url returns the correct path with options" do
    object = create(:topical_event, slug: "foo", topical_event_about_page: create(:topical_event_about_page))
    assert_equal "https://www.test.gov.uk/government/topical-events/foo/about?cachebust=123", object.topical_event_about_page.public_url(cachebust: "123")
  end

  should_not_accept_footnotes_in :body

  test "republishes topical event when its about page is created" do
    topical_event = create(:topical_event)

    Whitehall::PublishingApi.expects(:republish_async).with(topical_event)

    create(:topical_event_about_page, topical_event:)
  end

  test "republishes topical event when its about page is updated" do
    topical_event = create(:topical_event)
    about_page = create(:topical_event_about_page, topical_event:)

    Whitehall::PublishingApi.expects(:republish_async).with(topical_event)

    about_page.save!
  end

  test "republishes topical event when its about page is destroyed" do
    topical_event = create(:topical_event)
    about_page = create(:topical_event_about_page, topical_event:)

    Whitehall::PublishingApi.expects(:republish_async).with(topical_event)

    about_page.destroy!
  end
end

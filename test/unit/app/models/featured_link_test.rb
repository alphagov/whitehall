require "test_helper"

class FeaturedLinkTest < ActiveSupport::TestCase
  # These tests use organisations as a candidate, but any object with this module
  # can be used here. Ideally a seperate stub ActiveRecord object would be used.
  test "creating a new featured link republishes the linked linkable if it's an Organisation" do
    test_object = create(:organisation)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    create(:featured_link, linkable: test_object)
  end

  test "updating an existing featured link republishes the linked linkable if it's an Organisation" do
    test_object = create(:organisation)
    featured_link = create(:featured_link, linkable: test_object)
    featured_link.title = "Test"
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    featured_link.save!
  end

  test "deleting a featured link republishes the linked linkable if it's an Organisation" do
    test_object = create(:organisation)
    featured_link = create(:featured_link, linkable: test_object)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    featured_link.destroy!
  end

  test "creating a new featured link does not republish the linked linkable if it's not an Organisation" do
    test_object = create(:world_location)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).never
    create(:featured_link, linkable: test_object)
  end

  # moved from duplicate file
  test "should not be valid without a url" do
    link = build(:featured_link, title: "a title", url: nil)
    assert_not link.valid?
  end

  test "should not be valid without a title" do
    link = build(:featured_link, title: nil, url: "http://my.example.com/path")
    assert_not link.valid?
  end

  test "should not be valid with a url that doesn't start with http" do
    link = build(:featured_link, title: "a title", url: "not a link")
    assert_not link.valid?
  end

  test "should be valid with a url that starts with http" do
    link = build(:featured_link, title: "a title", url: "http://my.example.com/path")
    assert link.valid?
  end

  test "should accept multiple translations" do
    link = create(:featured_link)

    I18n.with_locale(:en) do
      link.update(url: "https://example.com", title: "Title in English")
    end
    I18n.with_locale(:cy) do
      link.update(url: "https://example.cy", title: "Title in Welsh")
    end

    I18n.with_locale(:en) do
      assert_equal "https://example.com", link.url
      assert_equal "Title in English", link.title
    end

    I18n.with_locale(:cy) do
      assert_equal "https://example.cy", link.url
      assert_equal "Title in Welsh", link.title
    end
  end
end

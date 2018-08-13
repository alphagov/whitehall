require 'test_helper'

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
    featured_link.destroy
  end

  test "creating a new featured link does not republish the linked linkable if it's not an Organisation" do
    test_object = create(:world_location)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).never
    create(:featured_link, linkable: test_object)
  end
end

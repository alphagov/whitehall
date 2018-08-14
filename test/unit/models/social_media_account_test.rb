require 'test_helper'

class SocialMediaAccountTest < ActiveSupport::TestCase
  # These tests use organisations as a candidate, but any object with this module
  # can be used here. Ideally a seperate stub ActiveRecord object would be used.
  test "destroy deletes related social media accounts" do
    test_object = create(:organisation)
    social_media_account = create(:social_media_account, socialable: test_object)
    test_object.destroy
    assert_nil SocialMediaAccount.find_by(id: social_media_account.id)
  end

  test "creating a new social media account republishes the linked socialable if it's an Organisation" do
    test_object = create(:organisation)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    create(:social_media_account, socialable: test_object)
  end

  test "updating an existing social media account republishes the linked socialable if it's an Organisation" do
    test_object = create(:organisation)
    social_media_account = create(:social_media_account, socialable: test_object)
    social_media_account.title = "Test"
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    social_media_account.save!
  end

  test "deleting a social media account republishes the linked socialable if it's an Organisation" do
    test_object = create(:organisation)
    social_media_account = create(:social_media_account, socialable: test_object)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    social_media_account.destroy
  end

  test "creating a new social media account does not republish the linked socialable if it's not an Organisation" do
    test_object = create(:world_location)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).never
    create(:social_media_account, socialable: test_object)
  end
end

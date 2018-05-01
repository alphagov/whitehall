require 'test_helper'

class FeatureTest < ActiveSupport::TestCase
  # These tests use organisations as a candidate, but any object with this module
  # can be used here. Ideally a seperate stub ActiveRecord object would be used.
  test "creating a new feature republishes the linked featurable if it's an Organisation" do
    test_object = create(:organisation)
    feature_list = create(:feature_list, featurable: test_object)
    Whitehall::PublishingApi.expects(:publish_async).with(test_object).once
    create(:feature, feature_list: feature_list)
  end

  test "updating an existing feature republishes the linked featurable if it's an Organisation" do
    test_object = create(:organisation)
    feature_list = create(:feature_list, featurable: test_object)
    feature = create(:feature, feature_list: feature_list)
    feature.alt_text = "Test"
    Whitehall::PublishingApi.expects(:publish_async).with(test_object).once
    feature.save!
  end

  test "deleting a feature republishes the linked featurable if it's an Organisation" do
    test_object = create(:organisation)
    feature_list = create(:feature_list, featurable: test_object)
    feature = create(:feature, feature_list: feature_list)
    Whitehall::PublishingApi.expects(:publish_async).with(test_object).once
    feature.destroy
  end

  test "creating a new feature does not republish the linked featurable if it's not an Organisation" do
    test_object = create(:world_location)
    feature_list = create(:feature_list, featurable: test_object)
    Whitehall::PublishingApi.expects(:publish_async).with(test_object).never
    create(:feature, feature_list: feature_list)
  end
end

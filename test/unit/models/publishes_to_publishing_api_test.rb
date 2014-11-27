require 'test_helper'
require 'sidekiq/testing'

class PublishesToPublishingApiTest < ActiveSupport::TestCase
  # publish_to_publishing_api runs on after_commit hook, so we need to disable
  # transactions for this test to allow it to run.
  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.clean_with :truncation
  end

  teardown do
    DatabaseCleaner.clean_with :truncation
  end

  test "generating a content_id" do
    SecureRandom.stubs(:uuid).returns("a random UUID")
    organisation = create(:organisation)

    assert organisation.valid?
    assert_equal organisation.content_id, "a random UUID"
  end

  test "create publishes to Publishing API" do
    organisation = build(:organisation)
    Whitehall::PublishingApi.expects(:publish).with(organisation)
    organisation.save
  end

  test "update publishes to Publishing API" do
    organisation = create(:organisation)
    Whitehall::PublishingApi.expects(:publish).with(organisation)
    organisation.update_attribute(:name, 'Edited org')
  end
end

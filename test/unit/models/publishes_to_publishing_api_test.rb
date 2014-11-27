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

  test "create triggers a PublishingApiWorker job" do
    Sidekiq::Testing.fake! do
      organisation = create(:organisation)
      assert_equal 1, PublishingApiWorker.jobs.size
    end
  end

  test "update triggers a PublishingApiWorker job" do
    Sidekiq::Testing.fake! do
      organisation = create(:organisation)
      PublishingApiWorker.jobs.clear
      organisation.update_attribute(:name, 'Edited org')
      assert_equal 1, PublishingApiWorker.jobs.size
    end
  end
end

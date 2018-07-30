require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class OperationalFieldPublishingTest < ActiveSupport::TestCase
  #api calls happen in after commit so we need to disable transactions
  self.use_transactional_tests = false

  setup do
    DatabaseCleaner.clean_with :truncation, pre_count: true
    stub_any_publishing_api_call
  end

  test "OperationalField is published to the Publishing API on save" do
    Sidekiq::Testing.inline! do
      operational_field = build(:operational_field)
      operational_field.save!

      assert_publishing_api_put_content(
        operational_field.content_id,
        PublishingApiPresenters.presenter_for(operational_field).content
      )

      assert_publishing_api_publish(
        operational_field.content_id,
        { update_type: 'major', locale: 'en' },
        1
      )
    end
  end
end

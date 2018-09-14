require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class OperationalFieldPublishingTest < ActiveSupport::TestCase
  setup do
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
        { update_type: nil, locale: 'en' },
        1
      )
    end
  end
end

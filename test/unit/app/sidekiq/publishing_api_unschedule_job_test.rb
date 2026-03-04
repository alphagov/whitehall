require "test_helper"

class PublishingApiUnscheduleJobTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "removes a publish intent when performed" do
    base_path = "/base_path/for/content.fr"
    expected_request = stub_publishing_api_destroy_intent(base_path)

    PublishingApiUnscheduleJob.new.perform(base_path)

    assert_requested expected_request
  end
end

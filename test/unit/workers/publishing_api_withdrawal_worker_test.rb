require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class PublishingApiWithdrawalWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test "publishes a 'gone' item for the supplied content id" do
    uuid = SecureRandom.uuid
    request = stub_publishing_api_unpublish(
      uuid,
      body: {
        type: "withdrawal",
        locale: "en",
        explanation: "This content is no longer valid",
      }
    )

    PublishingApiWithdrawalWorker.new.perform(
      uuid, "This content is no longer valid", "en"
    )

    assert_requested request
  end
end

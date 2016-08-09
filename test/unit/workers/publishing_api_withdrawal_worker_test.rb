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
        explanation: "<div class=\"govspeak\"><p><em>why?</em></p>\n</div>"
      }
    )

    PublishingApiWithdrawalWorker.new.perform(
      uuid, "*why?*", "en"
    )

    assert_requested request
  end
end

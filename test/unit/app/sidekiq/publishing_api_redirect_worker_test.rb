require "test_helper"
require "gds_api/test_helpers/publishing_api"

class PublishingApiRedirectWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  setup do
    document = create(:document)
    @uuid = document.content_id
    @base_path = "/government/this-needs-redirecting.fr"

    @destination = "/government/has-been-redirected.fr"
  end

  test "unpublished the item as a 'redirect' for the supplied content_id" do
    request = stub_publishing_api_unpublish(
      @uuid,
      body: {
        type: "redirect",
        locale: "fr",
        alternative_path: @destination,
        discard_drafts: true,
      },
    )

    PublishingApiRedirectWorker.new.perform(@uuid, @destination, "fr")

    assert_requested request
  end

  test "passes allow_draft if it is supplied" do
    request = stub_publishing_api_unpublish(
      @uuid,
      body: {
        type: "redirect",
        locale: "fr",
        alternative_path: @destination,
        allow_draft: true,
      },
    )

    PublishingApiRedirectWorker.new.perform(@uuid, @destination, "fr", true)

    assert_requested request
  end

  test "trims the destination url" do
    @destination = "/government/has-been-redirected.fr "
    request = stub_publishing_api_unpublish(
      @uuid,
      body: {
        type: "redirect",
        locale: "fr",
        alternative_path: "/government/has-been-redirected.fr",
        allow_draft: true,
      },
    )

    PublishingApiRedirectWorker.new.perform(@uuid, @destination, "fr", true)

    assert_requested request
  end

  test "avoids swallowing the error if there is a problem with the request" do
    publishing_api = Minitest::Mock.new
    def publishing_api.unpublish(_content_id, _options)
      raise GdsApi::HTTPUnprocessableEntity, "test"
    end

    Services.stub :publishing_api, publishing_api do
      assert_raises(GdsApi::HTTPUnprocessableEntity) do
        PublishingApiRedirectWorker.new.perform(@uuid, @destination, "fr", true)
      end
    end
  end
end

require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiRedirectWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  setup do
    @uuid = "a-uuid"
    SecureRandom.stubs(uuid: @uuid)
    @base_path = "/government/this-needs-redirecting"

    @content = {
      base_path: "/government/this-needs-redirecting",
      format: "redirect",
      publishing_app: "whitehall",
      redirects: [
        {
          path: "/government/this-needs-redirecting",
          type: "exact",
          destination: "/government/has-been-redirected"
        },
      ],
    }

    @redirects = [
      {
        path: @base_path,
        type: "exact",
        destination: "/government/has-been-redirected",
      },
    ]
  end

  test "publishes a 'redirect' item for the supplied base path" do
    requests = [
      stub_publishing_api_put_content(@uuid, @content),
      stub_publishing_api_patch_links(@uuid, links: {}),
      stub_publishing_api_publish(@uuid, update_type: 'major', locale: 'en')
    ]

    PublishingApiRedirectWorker.new.perform(@base_path, @redirects, "en")

    assert_all_requested requests
  end

  test "saves a draft 'redirect' item for the supplied base path if draft == true" do
    requests = [
      stub_publishing_api_put_content(@uuid, @content),
    ]

    PublishingApiRedirectWorker.new.perform(@base_path, @redirects, "en", true)

    assert_all_requested requests
  end
end

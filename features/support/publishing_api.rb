require "gds_api/publishing_api"
require "gds_api/test_helpers/publishing_api"
require_relative "mocha"

Before do
  publishing_api_v1_endpoint = File.join(
    Plek.find("publishing-api"),
    "publish-intent",
  )

  stub_request(:any, %r{\A#{publishing_api_v1_endpoint}})
  GdsApi::PublishingApi.any_instance.stubs(:discard_draft)
  GdsApi::PublishingApi.any_instance.stubs(:publish)
  GdsApi::PublishingApi.any_instance.stubs(:put_content)
  GdsApi::PublishingApi.any_instance.stubs(:patch_links)
  GdsApi::PublishingApi.any_instance.stubs(:unpublish)

  need1 = {
    "content_id" => SecureRandom.uuid,
    "format" => "need",
    "title" => "Need #1",
    "base_path" => "/government/needs/need-1",
    "links" => {},
  }

  need2 = {
    "content_id" => SecureRandom.uuid,
    "format" => "need",
    "title" => "Need #2",
    "base_path" => "/government/needs/need-2",
    "links" => {},
  }

  stub_request(:get, %r{\A#{Plek.find('publishing-api')}/v2/links})
    .to_return(body: { links: { meets_user_needs: [need1, need2] } }.to_json)

  stub_request(:get, %r{\A#{Plek.find('publishing-api')}/v2/expanded-links})
    .to_return(
      body: {
        expanded_links: {
          meets_user_needs: [
            {
              title: need1["title"],
              content_id: need1["content_id"],
              details: {
                role: "x",
                goal: "y",
                benefit: "z",
              },
            },
            {
              title: need2["title"],
              content_id: need2["content_id"],
              details: {
                role: "c",
                goal: "d",
                benefit: "e",
              },
            },
          ],
        },
      }.to_json,
    )

  stub_publishing_api_has_linkables([need1, need2], document_type: "need")
end

World(GdsApi::TestHelpers::PublishingApi)

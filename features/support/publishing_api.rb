require 'gds_api/publishing_api_v2'
require_relative '../../test/support/policy_tagging_helpers'
require_relative 'mocha'

Before do
  publishing_api_v1_endpoint = File.join(
    Plek.find('publishing-api'),
    "publish-intent"
  )
  stub_request(:any, %r{\A#{publishing_api_v1_endpoint}})
  GdsApi::PublishingApiV2.any_instance.stubs(:publish)
  GdsApi::PublishingApiV2.any_instance.stubs(:put_content)
  GdsApi::PublishingApiV2.any_instance.stubs(:patch_links)
  GdsApi::PublishingApiV2.any_instance.stubs(:unpublish)

  need_1 = {
      "content_id" => SecureRandom.uuid,
      "format" => "need",
      "title" => "Need #1",
      "base_path" => "/government/needs/need-1",
      "links" => {}
  }
  need_2 = {
      "content_id" => SecureRandom.uuid,
      "format" => "need",
      "title" => "Need #2",
      "base_path" => "/government/needs/need-2",
      "links" => {}
  }
  stub_request(:get, %r{\A#{Plek.find('publishing-api')}/v2/links})
    .to_return(body: { links: { meets_user_needs: [need_1, need_2] } }.to_json)

  stub_request(:get, %r{\A#{Plek.find('publishing-api')}/v2/expanded-links})
    .to_return(
      body: {
        expanded_links: {
          meets_user_needs: [
            {
              title: need_1["title"],
              content_id: need_1["content_id"],
              details: {
                role: "x",
                goal: "y",
                benefit: "z",
              }
            },
            {
              title: need_2["title"],
              content_id: need_2["content_id"],
              details: {
                role: "c",
                goal: "d",
                benefit: "e",
              },
            },
          ],
        },
      }.to_json
    )

  publishing_api_has_linkables([need_1, need_2], document_type: "need")

  stub_publishing_api_policies
end

World(PolicyTaggingHelpers)

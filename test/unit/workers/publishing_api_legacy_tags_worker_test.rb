require 'test_helper'

class PublishingApiLegacyTagsWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  setup do
    @edition = create :publication
    @taxon_uuid = SecureRandom.uuid
    @taxon_parent_uuid = SecureRandom.uuid
    @policy_area_uuid = SecureRandom.uuid
    @policy_uuid = SecureRandom.uuid
    @topic_uuid = SecureRandom.uuid

    publishing_api_has_linkables([{ content_id: @policy_uuid }], document_type: 'policy')
    publishing_api_has_linkables([{ content_id: @topic_uuid }], document_type: 'topic')
    create :topic, content_id: @policy_area_uuid

  end

  test "patches legacy taxon links for editions" do
    publishing_api_has_expanded_links({
      "content_id" => @taxon_uuid, "expanded_links" => {}
    })

    publishing_api_has_links_for_content_ids([@taxon_uuid], {
      @taxon_uuid => { links: { legacy_taxons: [@policy_area_uuid, @policy_uuid, @topic_uuid] } }
    })

    request = stub_publishing_api_patch_links(
      @edition.content_id,
      links: {
        policy_areas: [@policy_area_uuid], policies: [@policy_uuid], topics: [@topic_uuid]
      }
    )

    PublishingApiLegacyTagsWorker.new.perform(@edition.id, [@taxon_uuid])
    assert_requested request
  end

  test "patches legacy parent taxon links for editions" do
    publishing_api_has_expanded_links({
      "content_id" => @taxon_uuid,
      "expanded_links" => {
        "parent_taxons" => [{ "content_id" => @taxon_parent_uuid, "links" => { } }]
      }
    })

    publishing_api_has_links_for_content_ids([@taxon_uuid, @taxon_parent_uuid], {
      @taxon_parent_uuid => { links: { legacy_taxons: [@policy_area_uuid, @policy_uuid, @topic_uuid] } },
      @taxon_uuid => { links: {} }
    })

    request = stub_publishing_api_patch_links(
      @edition.content_id,
      links: {
        policy_areas: [@policy_area_uuid],
        policies: [@policy_uuid],
        topics: [@topic_uuid]
      }
    )

    PublishingApiLegacyTagsWorker.new.perform(@edition.id, [@taxon_uuid])
    assert_requested request
  end

  test "only patches supported legacy taxons for the edition" do
    @edition = create :edition

    publishing_api_has_expanded_links({
      "content_id" => @taxon_uuid, "expanded_links" => {}
    })

    publishing_api_has_links_for_content_ids([@taxon_uuid], {
      @taxon_uuid => { links: { legacy_taxons: [@policy_area_uuid, @policy_uuid, @topic_uuid] } }
    })

    request = stub_publishing_api_patch_links(
      @edition.content_id,
      links: {
        policy_areas: [@policy_area_uuid], policies: [@policy_uuid], topics: [@topic_uuid]
      }
    )

    PublishingApiLegacyTagsWorker.new.perform(@edition.id, [@taxon_uuid])
    assert_not_requested request
  end

  private 
  
  def publishing_api_has_links_for_content_ids(content_ids, links)
    stub_request(:post, GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT + "/links/by-content-id")
      .with(body: { content_ids: content_ids }).to_return(body: JSON.dump(links))
  end
end

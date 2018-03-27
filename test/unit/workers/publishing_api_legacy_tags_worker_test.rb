require 'test_helper'

class PublishingApiLegacyTagsWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  setup do
    @model = create :publication
    @taxon_uuid = SecureRandom.uuid
    @policy_area_uuid = SecureRandom.uuid
    @policy_uuid = SecureRandom.uuid
    @topic_uuid = SecureRandom.uuid
    @legacy_taxons = [@policy_area_uuid, @policy_uuid, @topic_uuid]

    @patch_links = { policy_areas: [@policy_area_uuid], topics: [@topic_uuid],
                     policies: [@policy_uuid] }

    publishing_api_has_linkables([{ content_id: @policy_uuid }], document_type: 'policy')
    publishing_api_has_linkables([{ content_id: @topic_uuid }], document_type: 'topic')
    publishing_api_has_expanded_links("content_id" => @taxon_uuid, "expanded_links" => {})
    publishing_api_has_links(content_id: @policy_uuid, links: {})
    publishing_api_has_links(content_id: @model.content_id, links: { taxons: [@taxon_uuid] })
    create :topic, content_id: @policy_area_uuid

    publishing_api_has_links_for_content_ids(
      @taxon_uuid => { links: { legacy_taxons: @legacy_taxons } }
    )
  end

  test "patches legacy taxon links for models" do
    request = stub_publishing_api_patch_links(@model.content_id, links: @patch_links)
    PublishingApiLegacyTagsWorker.new.perform(@model.id, @model.class.name)
    assert_requested request
  end

  test "only patches legacy taxons if supported" do
    @model = create :edition
    publishing_api_has_links(content_id: @model.content_id, links: { taxons: [@taxon_uuid] })
    request = stub_publishing_api_patch_links(@model.content_id, links: @patch_links)
    PublishingApiLegacyTagsWorker.new.perform(@model.id, @model.class.name)
    assert_not_requested request
  end

  test "saves legacy taxons links in the database" do
    PublishingApiLegacyTagsWorker.new.perform(@model.id, @model.class.name)
    assert_equal([@policy_uuid], @model.policy_content_ids)
    assert_equal([@policy_area_uuid], @model.topics.map(&:content_id))
    assert_equal([@topic_uuid], @model.specialist_sector_tags)
  end

  test "resets existing legacy taxons for models" do
    publishing_api_has_links(content_id: @model.content_id, links: {})
    publishing_api_has_links_for_content_ids({})
    patch_links = { "policy_areas" => [], "topics" => [], "policies" => [] }
    request = stub_publishing_api_patch_links(@model.content_id, links: patch_links)
    PublishingApiLegacyTagsWorker.new.perform(@model.id, @model.class.name)
    assert_requested request
  end

  test "adds policy areas from any legacy policies" do
    policy_parent_uuid = SecureRandom.uuid
    policy_links = { "policy_areas" => [policy_parent_uuid] }

    patch_links = { "policy_areas" => [policy_parent_uuid], "policies" => [@policy_uuid],
                    "topics" => [] }

    publishing_api_has_links_for_content_ids(
      @taxon_uuid => { links: { legacy_taxons: [@policy_uuid] } }
    )

    publishing_api_has_links("content_id" => @policy_uuid, "links" => policy_links)
    request = stub_publishing_api_patch_links(@model.content_id, links: patch_links)
    PublishingApiLegacyTagsWorker.new.perform(@model.id, @model.class.name)
    assert_requested request
  end

  test "adds legacy links from parent topic taxons" do
    @taxon_parent_uuid = SecureRandom.uuid

    publishing_api_has_expanded_links(
      "content_id" => @taxon_uuid,
      "expanded_links" => {
        "parent_taxons" => [{ "content_id" => @taxon_parent_uuid, "links" => {} }]
      }
    )

    publishing_api_has_links_for_content_ids(
      @taxon_uuid => { links: {} },
      @taxon_parent_uuid => { links: { legacy_taxons: @legacy_taxons } }
    )

    request = stub_publishing_api_patch_links(@model.content_id, links: @patch_links)
    PublishingApiLegacyTagsWorker.new.perform(@model.id, @model.class.name)
    assert_requested request
  end
end

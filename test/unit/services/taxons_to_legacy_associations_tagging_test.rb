require 'test_helper'

class TaxonsToLegacyAssociationsTaggingTest < ActiveSupport::TestCase
  test "handles policies" do
    policy = Policy.new(
      "content_id" => SecureRandom.uuid,
      "title" => "Test Policy",
      "base_path" => "/government/policies/test-policy",
      "internal_name" => "Test Policy"
    )
    taxon = taxon_mapped_to_policy(policy.content_id)

    Taxonomy::TopicTaxonomy
      .any_instance
      .stubs(:all_taxons)
      .returns([taxon])

    edition = create(:publication)
    edition.topics.delete_all

    Services.publishing_api
      .expects(:get_links)
      .with(policy.content_id)
      .raises(GdsApi::HTTPNotFound.new(404))

    TaxonsToLegacyAssociationsTagging.new.call(
      edition: edition,
      user: create(:user),
      selected_taxons: [taxon.content_id]
    )

    assert edition.policy_content_ids.count, 1
    assert edition.policy_content_ids.first, policy.content_id
  end

  test "handles policy areas" do
    policy_area = create(:topic)
    taxon = taxon_mapped_to_policy_area(policy_area.content_id)

    Taxonomy::TopicTaxonomy
      .any_instance
      .stubs(:all_taxons)
      .returns([taxon])

    edition = create(:publication)
    edition.topics.delete_all

    TaxonsToLegacyAssociationsTagging.new.call(
      edition: edition,
      user: create(:user),
      selected_taxons: [taxon.content_id]
    )

    assert edition.topics.count, 1
    assert edition.topics.first.content_id, policy_area.content_id
  end

  test "handles specialist sectors" do
    specialist_sector_content_id = SecureRandom.uuid
    taxon = taxon_mapped_to_specialist_sector(
      specialist_sector_content_id
    )

    Taxonomy::TopicTaxonomy
      .any_instance
      .stubs(:all_taxons)
      .returns([taxon])

    edition = create(:publication)
    edition.topics.delete_all

    TaxonsToLegacyAssociationsTagging.new.call(
      edition: edition,
      user: create(:user),
      selected_taxons: [taxon.content_id]
    )

    assert edition.specialist_sectors.count, 1
    assert edition.specialist_sectors.first.topic_content_id, specialist_sector_content_id
  end

  def taxon_mapped_to_policy(policy_content_id)
    Taxonomy::Taxon.new(
      title: "Taxon mapped to policy",
      base_path: "/mapped-to-policy",
      content_id: "4415339f-d907-46e1-bc55-2e0c4b313787",
      legacy_mapping: {
        "policy" => [
          {
            "content_id" => policy_content_id,
            "document_type" => "policy",
            "title" => "Test Policy"
          }
        ]
      }
    )
  end

  def taxon_mapped_to_policy_area(policy_area_content_id)
    Taxonomy::Taxon.new(
      title: "Taxon mapped to policy area",
      base_path: "/mapped-to-policy-area",
      content_id: "24a01d2e-e4c4-4abf-bcdc-322289f135d8",
      legacy_mapping: {
        "policy_area" => [
          {
            "content_id" => policy_area_content_id,
            "document_type" => "policy_area",
            "title" => "Test Policy Area"
          }
        ]
      }
    )
  end

  def taxon_mapped_to_specialist_sector(specialist_sector_content_id)
    Taxonomy::Taxon.new(
      title: "Taxon mapped to specialist sector",
      base_path: "/mapped-to-specialist-sector",
      content_id: "608f8936-c71e-4ce1-93a1-c0a5dd6ac7e4",
      legacy_mapping: {
        "topic" => [
          {
            "content_id" => specialist_sector_content_id,
            "document_type" => "topic",
            "title" => "Test Specialist Sector"
          }
        ]
      }
    )
  end
end

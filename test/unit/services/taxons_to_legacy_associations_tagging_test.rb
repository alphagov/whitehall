require 'test_helper'

class TaxonsToLegacyAssociationsTaggingTest < ActiveSupport::TestCase
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

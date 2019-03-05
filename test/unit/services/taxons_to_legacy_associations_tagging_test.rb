require 'test_helper'

class TaxonsToLegacyAssociationsTaggingTest < ActiveSupport::TestCase
  setup do
    @specialist_sector_content_id = SecureRandom.uuid
    @taxon = taxon_mapped_to_specialist_sector(
      @specialist_sector_content_id
    )

    Taxonomy::TopicTaxonomy
      .any_instance
      .stubs(:all_taxons)
      .returns([@taxon])

    @edition = create(:publication)
    @edition.topics.delete_all
  end

  test "handles specialist sectors" do
    TaxonsToLegacyAssociationsTagging.new.call(
      edition: @edition,
      user: create(:user),
      selected_taxons: [@taxon.content_id]
    )

    assert @edition.specialist_sectors.count, 1
    assert @edition.specialist_sectors.first.topic_content_id, @specialist_sector_content_id
  end

  test "it doesn't set specialist sectors if they're already set" do
    specialist_sector = FactoryBot.create(:specialist_sector, edition: @edition, topic_content_id: SecureRandom.uuid)

    TaxonsToLegacyAssociationsTagging.new.call(
      edition: @edition,
      user: create(:user),
      selected_taxons: [@taxon.content_id]
    )

    assert_equal(1, @edition.specialist_sectors.count)
    assert_equal(specialist_sector, @edition.specialist_sectors.first)
  end

  test "it doesn't set specialist sectors if they're already set and the edition is wrapped in a LocalisedModel" do
    specialist_sector = FactoryBot.create(:specialist_sector, edition: @edition, topic_content_id: SecureRandom.uuid)

    TaxonsToLegacyAssociationsTagging.new.call(
      edition: LocalisedModel.new(@edition, @edition.primary_locale),
      user: create(:user),
      selected_taxons: [@taxon.content_id]
    )

    assert_equal(1, @edition.specialist_sectors.count)
    assert_equal(specialist_sector, @edition.specialist_sectors.first)
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

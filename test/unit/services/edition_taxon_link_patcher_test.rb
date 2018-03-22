require 'test_helper'

class EditionTaxonLinkPatcherTest < ActiveSupport::TestCase
  include TaxonomyHelper

  setup do
    @edition = create :edition
    stub_taxonomy_with_all_taxons
    PublishingApiLegacyTagsWorker.stubs(:perform_async)
  end

  test "patches topic taxon links for the edition" do
    EditionTaxonLinkPatcher.new.call(
      edition: @edition,
      selected_taxons: [child_taxon_content_id],
      invisible_taxons: [],
      previous_version: "2",
    )

    assert_publishing_api_patch_links(
      @edition.content_id,
      links: { taxons: [child_taxon_content_id] },
      previous_version: "2"
    )
  end

  test "includes invisible links in the patch" do
    EditionTaxonLinkPatcher.new.call(
      edition: @edition,
      selected_taxons: [],
      invisible_taxons: [child_taxon_content_id],
      previous_version: "2",
    )

    assert_publishing_api_patch_links(
      @edition.content_id,
      links: { taxons: [child_taxon_content_id] },
      previous_version: "2"
    )
  end

  test "ignores parent taxons if a child is selected" do
    EditionTaxonLinkPatcher.new.call(
      edition: @edition,
      selected_taxons: [parent_taxon_content_id, child_taxon_content_id],
      invisible_taxons: [],
      previous_version: "2",
    )

    assert_publishing_api_patch_links(
      @edition.content_id,
      links: { taxons: [child_taxon_content_id] },
      previous_version: "2"
    )
  end
end

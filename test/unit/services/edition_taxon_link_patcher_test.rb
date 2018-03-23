require 'test_helper'

class EditionTaxonLinkPatcherTest < ActiveSupport::TestCase
  include TaxonomyHelper

  setup do
    @model = create :edition
    stub_taxonomy_with_all_taxons
    PublishingApiLegacyTagsWorker.stubs(:perform_async)
  end

  test "delegates patching links for legacy taxons" do
    PublishingApiLegacyTagsWorker.expects(:perform_async).with(
      @model.id, [child_taxon_content_id, parent_taxon_content_id]
    )

    EditionTaxonLinkPatcher.new.call(
      edition: @model,
      selected_taxons: [child_taxon_content_id],
      invisible_taxons: [parent_taxon_content_id],
      previous_version: "2",
    )
  end

  test "patches topic taxon links for the model" do
    EditionTaxonLinkPatcher.new.call(
      model: @model,
      selected_taxons: [child_taxon_content_id],
      invisible_taxons: [],
      previous_version: "2",
    )

    assert_publishing_api_patch_links(
      @model.content_id,
      links: { taxons: [child_taxon_content_id] },
      previous_version: "2"
    )
  end

  test "includes invisible links in the patch" do
    EditionTaxonLinkPatcher.new.call(
      model: @model,
      selected_taxons: [],
      invisible_taxons: [child_taxon_content_id],
      previous_version: "2",
    )

    assert_publishing_api_patch_links(
      @model.content_id,
      links: { taxons: [child_taxon_content_id] },
      previous_version: "2"
    )
  end

  test "ignores parent taxons if a child is selected" do
    EditionTaxonLinkPatcher.new.call(
      model: @model,
      selected_taxons: [parent_taxon_content_id, child_taxon_content_id],
      invisible_taxons: [],
      previous_version: "2",
    )

    assert_publishing_api_patch_links(
      @model.content_id,
      links: { taxons: [child_taxon_content_id] },
      previous_version: "2"
    )
  end
end

require 'test_helper'

class EditionWorldTaxonLinkPatcherTest < ActiveSupport::TestCase
  include TaxonomyHelper

  test 'sends patch links request to publishing api' do
    stub_taxonomy_with_world_taxons

    EditionWorldTaxonLinkPatcher.new.call(
      content_id: "12345",
      selected_taxons: [world_taxon, world_child_taxon_content_id],
      invisible_taxons: [],
      previous_version: "1",
    )

    assert_publishing_api_patch_links(
      "12345",
      links: {
        taxons: [world_child_taxon_content_id]
      },
      previous_version: "1"
    )
  end
end

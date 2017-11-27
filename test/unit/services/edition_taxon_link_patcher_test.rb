require 'test_helper'

class EditionTaxonLinkPatcherTest < ActiveSupport::TestCase
  include TaxonomyHelper

  test 'sends patch links request to publishing api' do
    stub_taxonomy_with_all_taxons

    EditionTaxonLinkPatcher.new.call(
      content_id: "1234",
      selected_taxons: [child_taxon_content_id],
      invisible_taxons: [],
      previous_version: "2",
    )

    assert_publishing_api_patch_links(
      "1234",
      links: {
        taxons: [child_taxon_content_id]
      },
      previous_version: "2"
    )
  end

  test 'ignores taxons if there is a more specific one' do
    stub_taxonomy_with_all_taxons

    EditionTaxonLinkPatcher.new.call(
      content_id: "1234",
      selected_taxons: [
        grandparent_taxon_content_id,
        parent_taxon_content_id,
        child_taxon_content_id
      ],
      invisible_taxons: [],
      previous_version: "2",
    )

    assert_publishing_api_patch_links(
      "1234",
      links: {
        taxons: [child_taxon_content_id]
      },
      previous_version: "2"
    )
  end
end

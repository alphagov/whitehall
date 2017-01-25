require 'test_helper'

class EditionTaxonomyTagFormTest < ActiveSupport::TestCase
  test '#load should request links to publishing-api' do
    content_id = "64aadc14-9bca-40d9-abb6-4f21f9792a05"
    taxons = ["c58fdadd-7743-46d6-9629-90bb3ccc4ef0"]

    publishing_api_has_links(
      {
        "content_id" => "64aadc14-9bca-40d9-abb6-4f21f9792a05",
        "links" => {
          "taxons" => taxons,
        },
        "version" => 1
      }
    )

    form = EditionTaxonomyTagForm.load(content_id)

    assert_equal(form.edition_content_id, content_id)
    assert_equal(form.selected_taxons, taxons)
    assert_equal(form.previous_version, 1)
  end
end

require 'test_helper'

class EditionTaxonomyTagFormTest < ActiveSupport::TestCase
  test '#load should request links to publishing-api' do
    content_id = "64aadc14-9bca-40d9-abb6-4f21f9792a05"
    taxons = ["df2e7a3e-2078-45de-a75a-fd37d027427e"]

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
    assert_equal(form.taxons, taxons)
    assert_equal(form.previous_version, 1)
  end

  test '#publish should send a patch links to publishing-api' do
    content_id = "64aadc14-9bca-40d9-abb6-4f21f9792a05"
    taxons = ["df2e7a3e-2078-45de-a75a-fd37d027427e"]

    form = EditionTaxonomyTagForm.new(
      edition_content_id: content_id,
      taxons: taxons,
      previous_version: 1,
    )

    form.publish!

    assert_publishing_api_patch_links(
      content_id,
      {
        links: {
          taxons: ["df2e7a3e-2078-45de-a75a-fd37d027427e"],
        },
        previous_version: 1
      }
    )
  end
end

require 'test_helper'

class EditionTaxonomyTagFormTest < ActiveSupport::TestCase
  include EducationTaxonomyHelper

  test "#load when publishing-api returns 404, selected_taxons should be '[]'" do
    content_id = "64aadc14-9bca-40d9-abb4-4f21f9792a05"

    body = {
      "error" => {
        "code" => 404,
        "message" => "Could not find link set with content_id: #{content_id}"
      }
    }.to_json

    stub_request(:get, %r{.*/v2/links/#{content_id}.*})
      .to_return(body: body, status: 404)

    form = EditionTaxonomyTagForm.load(content_id)

    assert_equal form.selected_taxons, []
  end

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

  test '#most_specific_taxons ignores taxons if there is a more specific one' do
    stub_education_taxonomy

    selected_taxons = [
      grandparent_taxon_content_id,
      parent_taxon_content_id,
      child_taxon_content_id
    ]

    expected_taxons = [child_taxon_content_id]

    form = EditionTaxonomyTagForm.new(
      selected_taxons: selected_taxons,
      edition_content_id: "abc",
      previous_version: 1
    )

    assert_equal form.most_specific_taxons, expected_taxons
  end
end

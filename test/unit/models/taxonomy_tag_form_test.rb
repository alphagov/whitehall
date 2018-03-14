require 'test_helper'

class TaxonomyTagFormTest < ActiveSupport::TestCase
  include TaxonomyHelper

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

    form = TaxonomyTagForm.load(content_id)

    assert_equal form.selected_taxons, []
  end

  test '#load should request links to publishing-api' do
    content_id = "64aadc14-9bca-40d9-abb6-4f21f9792a05"
    taxons = ["c58fdadd-7743-46d6-9629-90bb3ccc4ef0"]

    publishing_api_has_links(
      "content_id" => "64aadc14-9bca-40d9-abb6-4f21f9792a05",
      "links" => {
        "taxons" => taxons,
      },
      "version" => 1
    )

    form = TaxonomyTagForm.load(content_id)

    assert_equal(form.content_id, content_id)
    assert_equal(form.selected_taxons, taxons)
    assert_equal(form.previous_version, 1)
  end

  test '#invisible_draft_taxons returns all invisible draft taxons tagged to the content item' do
    content_id = "64aadc14-9bca-40d9-abb6-4f21f9792a05"

    publishing_api_has_links(
      "content_id" => content_id,
      "links" => {
        "taxons" => [
          "visible_id",
          "invisible_id"
        ]
      },
      "version" => 1
    )

    redis_cache_has_taxons(
      [
        build(:taxon_hash, content_id: 'visible_id', visibility: true),
        build(:taxon_hash, content_id: 'invisible_id', visibility: false)
      ]
    )

    form = TaxonomyTagForm.load(content_id)

    assert_equal ['invisible_id'], form.invisible_taxons
  end
end

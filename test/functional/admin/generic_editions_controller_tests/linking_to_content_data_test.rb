require 'test_helper'

class Admin::GenericEditionsController::LinkingToContentDataTest < ActionController::TestCase
  include TaxonomyHelper
  tests Admin::GenericEditionsController

  setup do
    login_as :writer
  end

  view_test "should link to content-data when published" do
    published_edition = create(:published_edition)
    stub_publishing_api_expanded_links_with_taxons(published_edition.content_id,
                                                   [taxon_with_parents, taxon_with_different_root, taxon_with_same_root])

    redis_cache_has_world_taxons([world_taxon])
    get :show, params: { id: published_edition }
    el = css_select("a[text()='View data about page']").first
    url = "https://content-data.test.gov.uk/metrics/government/generic-editions/#{published_edition.slug}"
    expected_attributes = {
      'href' => url,
      'data-track-category' => 'external-link-clicked',
      'data-track-action' => url,
      'data-track-label' => 'View data about page',
    }

    attributes = el.attributes.transform_values(&:value).slice(*expected_attributes.keys)

    assert_equal expected_attributes, attributes
  end

  view_test "should not link to content-data when unpublished" do
    draft_edition = create(:draft_edition)
    stub_publishing_api_expanded_links_with_taxons(draft_edition.content_id, [])

    get :show, params: { id: draft_edition }
    refute_select("a[text()='View data about page']")
  end
end

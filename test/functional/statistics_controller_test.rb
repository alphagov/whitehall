require "test_helper"
require "gds_api/test_helpers/content_store"

class StatisticsControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::ContentStore
  include TaxonomyHelper

  should_be_a_public_facing_controller
  should_redirect_json_in_english_locale

  def assert_publication_order(expected_order)
    actual_order = assigns(:publications).map(&:model).map(&:id)
    assert_equal expected_order.map(&:id), actual_order
  end

  setup do
    @content_item = content_item_for_base_path(
      "/government/statistics",
    )

    stub_content_store_has_item(@content_item["base_path"], @content_item)

    stub_taxonomy_with_all_taxons
    @rummager = stub
  end

  test "when locale is english it redirects to research and statistics" do
    get :index
    assert_response :redirect
  end

  test "when locale is english it redirects with params for finder-frontend" do
    get :index,
        params: {
          keywords: "one two",
          taxons: %w[one],
          departments: %w[all one two],
          from_date: "01/01/2014",
          to_date: "01/01/2014",
        }

    redirect_params_query = {
      content_store_document_type: "published_statistics",
      keywords: "one two",
      level_one_taxon: "one",
      organisations: %w[one two],
      public_timestamp: { from: "01/01/2014", to: "01/01/2014" },
    }.to_query

    assert_redirected_to "/search/research-and-statistics?#{redirect_params_query}"
  end
end

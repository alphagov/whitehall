require "test_helper"

class DocumentsControllerWorldwideSlimmerHeadersInclusionTest < ActionController::TestCase
  tests ::WorldLocationNewsArticlesController

  test "adds world locations header if the document is associated with a world location" do
    edition = create(:world_location_news_article)
    force_publish(edition)

    get :show, id: edition.document

    assert_response :success
    expected_header_value = "<#{edition.world_locations.first.analytics_identifier}>"
    assert_equal expected_header_value, response.headers["X-Slimmer-World-Locations"]
  end

  test "adds worldwide organisation to organisations header if the document is associated with a worldwide organisation" do
    edition = create(:world_location_news_article)
    force_publish(edition)

    get :show, id: edition.document

    assert_response :success
    expected_header_value = "<#{edition.worldwide_organisations.first.analytics_identifier}>"
    assert_equal expected_header_value, response.headers["X-Slimmer-Organisations"]
  end

end

require "test_helper"

class DocumentsControllerWorldwideSlimmerHeadersExclusionTest < ActionController::TestCase
  tests ::NewsArticlesController

  test "does not add world locations header if the document is not associated with a world location" do
    edition = create(:published_news_article)
    get :show, id: edition.document

    assert_response :success
    assert_nil response.headers["X-Slimmer-World-Locations"]
  end

  test "does not add worldwide organisation to organisations header if the document is not associated with a worldwide organisation" do
    edition = create(:published_news_article)
    get :show, id: edition.document

    assert_response :success
    assert_no_match /^<WO\d+>$/, response.headers["X-Slimmer-Organisations"]
  end

end

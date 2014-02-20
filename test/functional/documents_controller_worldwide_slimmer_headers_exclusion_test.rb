require "test_helper"

class DocumentsControllerWorldwideSlimmerHeadersExclusionTest < ActionController::TestCase
  tests ::StatisticalDataSetsController

  test "does not add world locations header if the document is not associated with a world location" do
    statistical_data_set = create(:statistical_data_set)
    force_publish(statistical_data_set)

    get :show, id: statistical_data_set.document

    assert_response :success
    assert_nil response.headers["X-Slimmer-World-Locations"]
  end

  test "does not add worldwide organisation to organisations header if the document is not associated with a worldwide organisation" do
    statistical_data_set = create(:statistical_data_set)
    force_publish(statistical_data_set)

    get :show, id: statistical_data_set.document

    assert_response :success
    assert_no_match /^<WO\d+>$/, response.headers["X-Slimmer-Organisations"]
  end

end

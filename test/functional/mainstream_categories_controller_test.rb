require "test_helper"

class MainstreamCategoriesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "show category lists all published detailed guides in that category" do
    category = create(:mainstream_category)
    detailed_guide = create(:published_detailed_guide, primary_mainstream_category: category)
    other_guide = create(:published_detailed_guide, other_mainstream_categories: [category])

    get :show, id: category

    assert_select_object detailed_guide
    assert_select_object other_guide
  end

  test "show category does not list any draft detailed guides in that category" do
    category = create(:mainstream_category)
    detailed_guide = create(:draft_detailed_guide, primary_mainstream_category: category)

    get :show, id: category

    refute_select_object detailed_guide
  end

  test "show sets breadcrumb trail" do
    category = create(:mainstream_category)
    sentinel = stub("breadcrumb", valid?: true, to_hash: {"this_is_just_a_placeholder" => true})
    BreadcrumbTrail.stubs(:for).with(category).returns(sentinel)

    get :show, id: category

    artefact_headers = ActiveSupport::JSON.decode(response.headers[Slimmer::Headers::ARTEFACT_HEADER])

    assert_equal sentinel.to_hash, artefact_headers
  end

end

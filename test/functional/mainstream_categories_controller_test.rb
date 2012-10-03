require "test_helper"

class MainstreamCategoriesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "show orders guides alphabetically by title" do
    category = create(:mainstream_category)
    detailed_guide_a = create(:published_detailed_guide, primary_mainstream_category: category, title: "guide-a")
    detailed_guide_c = create(:published_detailed_guide, primary_mainstream_category: category, title: "guide-c")
    detailed_guide_b = create(:published_detailed_guide, primary_mainstream_category: category, title: "guide-b")

    get :show, parent_tag: category.parent_tag, id: category

    assert_equal [detailed_guide_a, detailed_guide_b, detailed_guide_c], assigns(:detailed_guides)
  end

  test "show category lists all published detailed guides in that category" do
    category = create(:mainstream_category)
    detailed_guide = create(:published_detailed_guide, primary_mainstream_category: category)
    other_guide = create(:published_detailed_guide, other_mainstream_categories: [category])

    get :show, parent_tag: category.parent_tag, id: category

    assert_select_object detailed_guide
    assert_select_object other_guide
  end

  test "show responds with 404 if category doesn't exist" do
    get :show, parent_tag: 'fruit/apples', id: 'prince-edward'

    assert_equal 404, response.status
  end

  test "show responds with 404 if parent tag is incorrect doesn't exist" do
    category = create(:mainstream_category)

    get :show, parent_tag: 'wrong/tag', id: category

    assert_equal 404, response.status
  end

  test "show category does not list any draft detailed guides in that category" do
    category = create(:mainstream_category)
    detailed_guide = create(:draft_detailed_guide, primary_mainstream_category: category)

    get :show, parent_tag: category.parent_tag, id: category

    refute_select_object detailed_guide
  end

  test "show sets breadcrumb trail" do
    category = create(:mainstream_category)
    sentinel = stub("breadcrumb", valid?: true, to_hash: {"this_is_just_a_placeholder" => true})
    BreadcrumbTrail.stubs(:for).with(category).returns(sentinel)

    get :show, parent_tag: category.parent_tag, id: category

    artefact_headers = ActiveSupport::JSON.decode(response.headers[Slimmer::Headers::ARTEFACT_HEADER])

    assert_equal sentinel.to_hash, artefact_headers
  end

end

require "test_helper"

class MainstreamCategoriesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "show category lists all published specialist guides in that category" do
    category = create(:mainstream_category)
    specialist_guide = create(:published_specialist_guide, primary_mainstream_category: category)
    other_guide = create(:published_specialist_guide, other_mainstream_categories: [category])

    get :show, id: category

    assert_select_object specialist_guide
    assert_select_object other_guide
  end

  test "show category does not list any draft specialist guides in that category" do
    category = create(:mainstream_category)
    specialist_guide = create(:draft_specialist_guide, primary_mainstream_category: category)

    get :show, id: category

    refute_select_object specialist_guide
  end

end

require "test_helper"

class InternationalPrioritiesControllerTest < ActionController::TestCase
  test "index displays list of published international priorities" do
    priority_1 = create(:published_international_priority)
    priority_2 = create(:published_international_priority)

    get :index

    assert_select ".international_priorities" do
      assert_select_object priority_1
      assert_select_object priority_2
    end
  end

  test "show displays published international priority details" do
    priority = create(:published_international_priority, title: "priority-title", body: "priority-body")

    get :show, id: priority.document_identity

    assert_select ".title", "priority-title"
    assert_select ".body", "priority-body"
  end
end

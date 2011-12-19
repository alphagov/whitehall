require "test_helper"

class InternationalPrioritiesControllerTest < ActionController::TestCase
  should_render_a_list_of :international_priorities
  should_show_the_countries_associated_with :international_priority

  test "show displays international priority details" do
    priority = create(:published_international_priority,
      title: "priority-title",
      body: "priority-body",
    )

    get :show, id: priority.document_identity

    assert_select ".title", "priority-title"
    assert_select ".body", "priority-body"
  end
end

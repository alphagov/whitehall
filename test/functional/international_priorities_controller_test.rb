require "test_helper"

class InternationalPrioritiesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_render_a_list_of :international_priorities
  should_show_the_countries_associated_with :international_priority
  should_display_inline_images_for :international_priority
  should_not_display_lead_image_for :international_priority
  should_show_change_notes :international_priority

  test "show displays international priority details" do
    priority = create(:published_international_priority,
      title: "priority-title",
      body: "priority-body",
    )

    get :show, id: priority.doc_identity

    assert_select ".page_title", "priority-title"
    assert_select ".body", "priority-body"
  end

  test "should display the associated organisations" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)
    third_organisation = create(:organisation)
    document = create(:published_international_priority, organisations: [first_organisation, second_organisation])

    get :show, id: document.doc_identity

    assert_select '#document_organisations' do
      assert_select_object first_organisation
      assert_select_object second_organisation
      refute_select_object third_organisation
    end
  end

  test "should not display an empty list of organisations" do
    document = create(:published_international_priority, organisations: [])

    get :show, id: document.doc_identity

    refute_select "#organisations"
  end
end

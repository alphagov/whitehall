require "test_helper"

class Admin::TopicalEventsControllerTest < ActionController::TestCase
  setup do
    login_as_preview_design_system_user(:writer)
  end

  should_be_an_admin_controller
  should_render_bootstrap_implementation_with_preview_next_release

  view_test "GET :show lists the topical event details" do
    topical_event = create(:topical_event)
    get :show, params: { id: topical_event }

    assert_response :success
    assert_select "h1", topical_event.name
  end

  view_test "GET :new renders topical event form" do
    get :new

    assert_response :success
    assert_select "input[name='topical_event[name]']"
  end

  test "POST :create saves the topical event" do
    assert_difference("TopicalEvent.count") do
      post :create, params: { topical_event: { name: "Event", description: "Event description", summary: "Event summary" } }
    end

    assert_response :redirect

    topical_event = TopicalEvent.last
    assert_equal "Event", topical_event.name
    assert_equal "Event description", topical_event.description
  end

  test "GET :index lists the topical events" do
    topical_event_c = create(:topical_event, name: "Topic C")
    topical_event_a = create(:topical_event, name: "Topic A")
    topical_event_b = create(:topical_event, name: "Topic B")

    get :index

    assert_response :success
    assert_equal(assigns(:topical_events), [topical_event_a, topical_event_b, topical_event_c])
  end

  view_test "GET :index page has the View link to show page" do
    topical_event = create(:topical_event)
    get :index
    assert_select "a[href=?]", admin_topical_event_path(topical_event), text: /View/
  end

  view_test "GET :edit renders the topical event form" do
    topical_event = create(:topical_event)
    get :edit, params: { id: topical_event }

    assert_response :success
    assert_select "input[name='topical_event[name]'][value='#{topical_event.name}']"
  end

  test "PUT :update saves changes to the topical event" do
    topical_event = create(:topical_event)
    put :update, params: { id: topical_event, topical_event: { name: "New name" } }

    assert_response :redirect
    assert_equal "New name", topical_event.reload.name
  end

  test "GET :confirm_destroy calls correctly" do
    topical_event = create(:topical_event)

    get :confirm_destroy, params: { id: topical_event.id }

    assert_response :success
    assert_equal topical_event, assigns(:topical_event)
  end

  test "DELETE :destroy deletes the topical event" do
    topical_event = create(:topical_event)
    delete :destroy, params: { id: topical_event }

    assert_response :redirect
    assert topical_event.reload.deleted?
  end
end

require "test_helper"

class Admin::TopicalEventAboutPagesControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @topical_event = create(:topical_event)
  end

  view_test "GET show prompts user to create an about page" do
    get :show, params: { topical_event_id: @topical_event.to_param }
    assert_response :success
    assert_select "h1", @topical_event.name
    assert_select "p", /doesn’t yet have a page/
  end

  view_test "GET new allows user to enter copy for new about page" do
    get :new, params: { topical_event_id: @topical_event.to_param }
    assert_select 'textarea[name*="summary"]'
  end

  test "POST create saves a new about page" do
    assert_difference "TopicalEventAboutPage.count" do
      post :create, params: { topical_event_id: @topical_event.to_param, topical_event_about_page: attributes_for(:topical_event_about_page) }
    end
    @topical_event.reload
    assert_not_nil @topical_event.topical_event_about_page, "expected topical event to have an about page"
  end

  view_test "GET edit shows the form for editing an about page" do
    about = create(:topical_event_about_page, topical_event: @topical_event)
    get :edit, params: { topical_event_id: @topical_event.to_param }
    assert_select 'textarea[name*="summary"]', text: /#{about.summary}/
  end

  test "PUT update saves changes to the about page" do
    about = create(:topical_event_about_page, topical_event: @topical_event)
    put :update, params: { topical_event_id: @topical_event.to_param, topical_event_about_page: { name: "New name" } }
    assert_equal "New name", about.reload.name
  end
end

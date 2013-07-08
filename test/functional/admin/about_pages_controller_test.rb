require 'test_helper'

class Admin::AboutPagesControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @topical_event = create(:topical_event)
  end

  view_test "GET show prompts user to create an about page" do
    get :show, topical_event_id: @topical_event.to_param
    assert_response :success
    assert_select 'h1', @topical_event.name
    assert_select 'p', /doesn't yet have a page/
  end

  view_test "GET new allows user to enter copy for new about page" do
    get :new, topical_event_id: @topical_event.to_param
    assert_select 'textarea[name*="summary"]'
  end

  test "POST create saves a new about page" do
    assert_difference 'AboutPage.count' do
      post :create, topical_event_id: @topical_event.to_param, about_page: attributes_for(:about_page)
    end
    assert_not_nil @topical_event.about_page, "expected topical event to have an about page"
  end

  view_test "GET edit shows the form for editing an about page" do
    about = create(:about_page, topical_event: @topical_event)
    get :edit, topical_event_id: @topical_event.to_param
    assert_select 'textarea[name*="summary"]', text: /#{about.summary}/
  end

  test "PUT update saves changes to the about page" do
    about = create(:about_page, topical_event: @topical_event)
    put :update, topical_event_id: @topical_event.to_param, about_page: { name: 'New name' }
    assert_equal 'New name', about.reload.name
  end
end

require 'test_helper'

class Admin::AboutPagesControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @subject = create(:topical_event)
  end

  view_test "GET show prompts user to create an about page" do
    get :show, topical_event_id: @subject.to_param
    assert_response :success
    assert_select 'h1', @subject.name
    assert_select 'p', /doesn't yet have a page/
  end

  view_test "GET new allows user to enter copy for new about page" do
    get :new, topical_event_id: @subject.to_param
    assert_select 'textarea[name*="summary"]'
  end

  view_test "POST create saves a new about page" do
    assert_difference 'AboutPage.count' do
      post :create, topical_event_id: @subject.to_param, about_page: attributes_for(:about_page)
    end
    assert_not_nil @subject.about_page, "expected subject to have an about page"
  end
end

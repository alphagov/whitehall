require "test_helper"

class Admin::FlexiblePagesControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :writer

    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:flexible_pages, true)
  end

  teardown do
    @test_strategy.switch!(:flexible_pages, false)
  end

  test "GET new returns a not found response when the flexible pages feature flag is disabled" do
    @test_strategy.switch!(:flexible_pages, false)
    get :new
    assert_response :not_found
  end

  test "POST create re-renders the new edition template with the submitted flexible page content if the form is invalid" do
    flexible_page_content = {
      "page_title" => {
        "heading_text" => "foo",
      },
    }
    post :create, params: { edition: { flexible_page_type: "history_page", flexible_page_content: } }
    assert_template "admin/editions/new"
  end
end

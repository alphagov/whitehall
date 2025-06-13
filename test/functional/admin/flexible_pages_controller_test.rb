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
end

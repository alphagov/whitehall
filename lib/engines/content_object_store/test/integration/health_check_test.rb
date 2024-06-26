require "test_helper"

class HealthcheckTest < ActionDispatch::IntegrationTest
  test "GET /government/admin/content-object-store/health-check returns 200 to demonstrate the ContentObjectStore engine is installed correctly" do
    get "/government/admin/content-object-store/health-check"
    assert_equal 200, status
  end
end

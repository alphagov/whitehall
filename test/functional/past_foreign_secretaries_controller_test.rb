require "test_helper"

class PastForeignSecretariesControllerTest < ActionController::TestCase
  view_test "GET :show renders a past foreign secretary" do
    get :show, params: { id: "edward-wood" }

    assert_select "h2.govuk-heading-m", text: "Edward Frederick Lindley Wood, Viscount Halifax"
  end

  view_test "GET :index renders past foreign secretaries" do
    get :index

    assert_select "h1", text: "Past Foreign Secretaries"

    assert_select "div.featured-profiles" do
      assert_select "h2.profiles", text: "Selection of profiles"
      assert_select "li.person", 10
    end
  end

  test "GET :show renders 'not found' for invalid foreign secretary name" do
    get :show, params: { id: "pete" }

    assert_equal @controller.status, 404
  end
end

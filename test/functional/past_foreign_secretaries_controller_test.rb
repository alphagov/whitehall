require "test_helper"

class PastForeignSecretariesControllerTest < ActionController::TestCase
  view_test "GET :show renders a past foreign secretary" do
    get :show, params: { id: "edward-wood" }

    assert_select "h2.govuk-heading-m", text: "Edward Frederick Lindley Wood, Viscount Halifax"
  end

  view_test "GET :index renders past foreign secretaries" do
    get :index

    assert_select "h1", text: "Past Foreign Secretaries"
    assert_select ".gem-c-heading.govuk-heading-l.gem-c-heading--padding.gem-c-heading--border-top-2", text: "Selection of profiles"
    assert_select "div.gem-c-image-card", 10
  end

  test "GET :show renders 'not found' for invalid foreign secretary name" do
    get :show, params: { id: "pete" }

    assert_equal @controller.status, 404
  end
end

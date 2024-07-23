require "test_helper"

class Admin::MoreControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  view_test "GET #index renders the 'More' page with a correctly formatted list of links" do
    get :index

    assert_response :success
    assert_select "h1.govuk-heading-xl", text: "More"
    assert_select ".govuk-list"
    assert_select "a.govuk-link", text: "Cabinet ministers order"
  end

  view_test "GET #index renders Fields of Operation and Sitewide settings list option when the user has GDS Editor permission and organisation is GDS" do
    organisation = create(:organisation, name: "government-digital-service")
    login_as(:gds_editor, organisation)

    get :index

    assert_select ".govuk-list"
    assert_select "a.govuk-link", text: "Fields of operation"
    assert_select "a.govuk-link", text: "Sitewide settings"
  end

  view_test "GET #index renders Fields of Operation list option and not show Sitewide settings when the user's organisation is Ministry of Defence" do
    organisation = create(:organisation, name: "ministry-of-defence", handles_fatalities: true)
    login_as(:writer, organisation)

    get :index

    assert_select ".govuk-list"
    assert_select "a.govuk-link", text: "Fields of operation"
    refute_select "a.govuk-link", text: "Sitewide settings"
  end

  view_test "GET #index does not renders Fields of Operation and Sitewide settings option when the user's organisation is not GDS nor Ministry of Defence." do
    organisation = create(:organisation, name: "cabinet-minister")
    login_as(:writer, organisation)

    get :index

    assert_select ".govuk-list"
    refute_select "a.govuk-link", text: "Fields of operation"
    refute_select "a.govuk-link", text: "Sitewide settings"
  end

  view_test "GET #index renders Worldwide Organisations with link to editions index" do
    get :index

    assert_select ".govuk-list"
    assert_select "a.govuk-link[href=?]", "/government/admin/editions?type=worldwide_organisation", text: "Worldwide organisations"
  end

  view_test "GET #index does not render Emergency Banner option when the user is not a GDS Admin." do
    organisation = create(:organisation, name: "cabinet-minister")
    login_as(:writer, organisation)

    get :index

    assert_select ".govuk-list"
    refute_select "a.govuk-link", text: "Emergency banner"
  end

  view_test "GET #index renders Emergency Banner option when the user is a GDS Admin." do
    organisation = create(:organisation, name: "government-digital-service")
    login_as(:gds_admin, organisation)

    get :index

    assert_select ".govuk-list"
    assert_select "a.govuk-link", text: "Emergency banner"
  end

  view_test "GET #index does not render Republish content option when the user is not a GDS Admin." do
    organisation = create(:organisation, name: "cabinet-minister")
    login_as(:writer, organisation)

    get :index

    assert_select ".govuk-list"
    refute_select "a.govuk-link", text: "Republish content"
  end

  view_test "GET #index renders Republish content option when the user is a GDS Admin." do
    organisation = create(:organisation, name: "government-digital-service")
    login_as(:gds_admin, organisation)

    get :index

    assert_select ".govuk-list"
    assert_select "a.govuk-link", text: "Republish content"
  end
end

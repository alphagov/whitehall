require "test_helper"

class Admin::WorldwideOrganisationPagesControllerTest < ActionController::TestCase
  setup { login_as :user }

  should_be_an_admin_controller

  view_test "GET :index returns a list of worldwide organisation pages" do
    worldwide_organisation = create(:editionable_worldwide_organisation, title: "British Antarctic Territory")
    create(:worldwide_organisation_page, edition: worldwide_organisation)
    create(:worldwide_organisation_page, edition: worldwide_organisation, corporate_information_page_type: CorporateInformationPageType::Recruitment)

    get :index, params: { editionable_worldwide_organisation_id: worldwide_organisation }

    assert_response :success
    assert_template :index
    assert_select "h1", "British Antarctic Territory"
    assert_select "h2", "Pages within this organisation"
    assert_select "h2", "Publication scheme"
    assert_select "h2", "Working for British Antarctic Territory"
  end
end

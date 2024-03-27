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

  view_test "GET :new displays the worldwide organisation page fields" do
    worldwide_organisation = create(:editionable_worldwide_organisation, title: "British Antarctic Territory")

    get :new, params: { editionable_worldwide_organisation_id: worldwide_organisation }

    assert_response :success
    assert_template :new

    assert_select "form#new_worldwide_organisation_page" do
      assert_select "select[name='worldwide_organisation_page[corporate_information_page_type_id]']"
      assert_select "textarea[name='worldwide_organisation_page[summary]']"
      assert_select "textarea[name='worldwide_organisation_page[body]']"
    end
  end

  test "POST :create should create a new worldwide organisation page" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    post :create,
         params: {
           worldwide_organisation_page: {
             corporate_information_page_type_id: CorporateInformationPageType::PublicationScheme.id,
             summary: "Some summary",
             body: "Some body",
           },
           editionable_worldwide_organisation_id: worldwide_organisation.id,
         }

    assert_redirected_to admin_editionable_worldwide_organisation_pages_path(worldwide_organisation)
    assert_equal 1, worldwide_organisation.reload.pages.count
    assert_equal 2, worldwide_organisation.pages.first.corporate_information_page_type_id
    assert_equal "Some summary", worldwide_organisation.pages.first.summary
    assert_equal "Some body", worldwide_organisation.pages.first.body
  end
end

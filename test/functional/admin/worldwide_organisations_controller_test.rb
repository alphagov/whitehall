require "test_helper"
require "support/concerns/admin_edition_controller/creating_tests"
require "support/concerns/admin_edition_controller/edition_editing_tests"
require "support/concerns/admin_edition_controller/only_lead_organisations_tests"
require "support/concerns/admin_edition_controller/access_limiting_tests"

class Admin::WorldwideOrganisationsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  include AdminEditionController::CreatingTests
  include AdminEditionController::EditionEditingTests
  include AdminEditionController::OnlyLeadOrganisationsTests
  include AdminEditionController::AccessLimitingTests

  should_be_an_admin_controller
  should_allow_scheduled_publication_of :worldwide_organisation
  should_allow_association_between_roles_and :worldwide_organisation
  should_allow_association_between_world_locations_and :worldwide_organisation

  test "POST :create - creates a default news image" do
    post :create,
         params: {
           edition: controller_attributes_for(
             :worldwide_organisation,
             default_news_image_attributes: {
               file: upload_fixture("minister-of-funk.960x640.jpg"),
             },
           ),
         }
    worldwide_organisation = WorldwideOrganisation.last
    assert_equal "minister-of-funk.960x640.jpg", worldwide_organisation.default_news_image.file.file.filename
    assert_equal "Your document has been saved", flash[:notice]
    assert_redirected_to admin_worldwide_organisation_path(worldwide_organisation)
  end

  test "PUT :update - updates existing default new image when image file is replaced" do
    worldwide_organisation = create(:draft_worldwide_organisation, :with_default_news_image)
    default_news_image_id = worldwide_organisation.default_news_image.id

    put :update,
        params: {
          id: worldwide_organisation.id,
          edition: controller_attributes_for(
            :worldwide_organisation,
            default_news_image_attributes: {
              id: default_news_image_id,
              file: upload_fixture("big-cheese.960x640.jpg"),
            },
          ),
        }
    worldwide_organisation = WorldwideOrganisation.last
    assert_equal "big-cheese.960x640.jpg", worldwide_organisation.default_news_image.file.file.filename
    assert_equal "Your document has been saved", flash[:notice]
    assert_redirected_to admin_worldwide_organisation_path(worldwide_organisation)
  end

  test "PUT :update - updates the main office" do
    offices = [create(:worldwide_office), create(:worldwide_office)]
    worldwide_organisation = create(:worldwide_organisation, offices:)

    put :update,
        params: {
          id: worldwide_organisation.id,
          edition: controller_attributes_for(
            :worldwide_organisation,
            main_office_id: offices.last.id,
          ),
        }

    assert_equal offices.last, worldwide_organisation.reload.main_office
    assert_equal "Your document has been saved", flash[:notice]
    assert_redirected_to admin_worldwide_organisation_path(worldwide_organisation)
  end

  view_test "GET :new does not display main office selection" do
    get :new

    refute_select "select#edition_main_office_id"
  end

  view_test "GET :edit does display main office selection if there are multiple offices" do
    offices = [create(:worldwide_office), create(:worldwide_office)]
    worldwide_organisation = create(:worldwide_organisation, offices:)

    get :edit, params: { id: worldwide_organisation.id }

    assert_select "select#edition_main_office_id"
  end

private

  def edition_type
    :worldwide_organisation
  end

  def controller_attributes_for(edition_type, attributes = {})
    super.merge(
      role_ids: [create(:role).id],
      world_location_ids: [create(:world_location).id],
    )
  end
end

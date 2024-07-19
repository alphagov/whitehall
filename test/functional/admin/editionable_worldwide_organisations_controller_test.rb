require "test_helper"

class Admin::EditionableWorldwideOrganisationsControllerTest < ActionController::TestCase
  setup do
    feature_flags.switch! :editionable_worldwide_organisations, true
    login_as :writer
  end

  should_be_an_admin_controller
  should_allow_creating_of :editionable_worldwide_organisation
  should_allow_editing_of :editionable_worldwide_organisation
  should_allow_only_lead_organisations_for :editionable_worldwide_organisation
  should_prevent_modification_of_unmodifiable :editionable_worldwide_organisation
  should_allow_scheduled_publication_of :editionable_worldwide_organisation
  should_allow_access_limiting_of :editionable_worldwide_organisation
  should_allow_association_between_roles_and :editionable_worldwide_organisation
  should_allow_association_between_world_locations_and :editionable_worldwide_organisation

  test "actions are forbidden when the editionable_worldwide_organisations feature flag is disabled" do
    feature_flags.switch! :editionable_worldwide_organisations, false
    worldwide_organisation = create(:editionable_worldwide_organisation)

    get :show, params: { id: worldwide_organisation.id }

    assert_response :forbidden
  end

  test "POST :create - creates a default news image" do
    post :create,
         params: {
           edition: controller_attributes_for(
             :editionable_worldwide_organisation,
             default_news_image_attributes: {
               file: upload_fixture("minister-of-funk.960x640.jpg"),
             },
           ),
         }
    worldwide_organisation = EditionableWorldwideOrganisation.last
    assert_equal "minister-of-funk.960x640.jpg", worldwide_organisation.default_news_image.file.file.filename
    assert_equal "Your document has been saved", flash[:notice]
    assert_redirected_to admin_editionable_worldwide_organisation_path(worldwide_organisation)
  end

  test "PUT :update - updates existing default new image when image file is replaced" do
    worldwide_organisation = create(:draft_editionable_worldwide_organisation, :with_default_news_image)
    default_news_image_id = worldwide_organisation.default_news_image.id

    put :update,
        params: {
          id: worldwide_organisation.id,
          edition: controller_attributes_for(
            :editionable_worldwide_organisation,
            default_news_image_attributes: {
              id: default_news_image_id,
              file: upload_fixture("big-cheese.960x640.jpg"),
            },
          ),
        }
    worldwide_organisation = EditionableWorldwideOrganisation.last
    assert_equal "big-cheese.960x640.jpg", worldwide_organisation.default_news_image.file.file.filename
    assert_equal "Your document has been saved", flash[:notice]
    assert_redirected_to admin_editionable_worldwide_organisation_path(worldwide_organisation)
  end

private

  def controller_attributes_for(edition_type, attributes = {})
    super.merge(
      role_ids: [create(:role).id],
      world_location_ids: [create(:world_location).id],
    )
  end
end

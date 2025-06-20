require "test_helper"

class Admin::WorldwideOrganisationsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller
  should_allow_creating_of :worldwide_organisation
  should_show_new_warning_message_for :worldwide_organisation
  should_allow_editing_of :worldwide_organisation
  should_allow_only_lead_organisations_for :worldwide_organisation
  should_prevent_modification_of_unmodifiable :worldwide_organisation
  should_allow_scheduled_publication_of :worldwide_organisation
  should_allow_access_limiting_of :worldwide_organisation
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

  view_test "viewing a readonly representation of this worldwide organisation" do
    worldwide_organisation = create(:published_worldwide_organisation)
    get :view, params: { id: worldwide_organisation }

    assert_select "form#edit_edition fieldset[disabled='disabled']" do
      assert_select "textarea[name='edition[logo_formatted_name]']"
      assert_select "select[name='edition[world_location_ids][]']"
      assert_select "select[name='edition[role_ids][]']"
    end
  end

private

  def controller_attributes_for(edition_type, attributes = {})
    super.merge(
      role_ids: [create(:role).id],
      world_location_ids: [create(:world_location).id],
    )
  end
end

require "test_helper"

class Admin::LicencesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
    @licence = create(:licence)
    @sector = create(:sector)
    @activity = create(:activity, sectors: [@sector])
  end

  should_be_an_admin_controller

  test "GET :show licence details" do
    get :show, params: { id: @licence.id }

    assert_response :success
    assert_template :show
    assert_equal @licence, assigns(:licence)
  end

  test "PUT :update changes licence details" do
    description = "Licence description"

    patch :update,
          params: {
            id: @licence.id,
            licence: {
              title: "title",
              description: description,
              sector_ids: [@sector.id],
              activity_id: @activity.id,
              external_link: true,
            },
          }

    @licence.reload

    assert_redirected_to admin_licences_path
    assert_equal %("#{@licence.title}" saved.), flash[:notice]
    assert_equal description, @licence.description
    assert_equal @activity.id, @licence.activity_id
    assert_equal @sector.title, @licence.sectors.first.title
  end
end

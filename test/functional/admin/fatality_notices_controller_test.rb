require 'test_helper'

class Admin::FatalityNoticesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller
  should_require_fatality_handling_permission_to_access :fatality_notice, :new, :edit

  should_allow_creating_of :fatality_notice
  should_allow_editing_of :fatality_notice

  should_allow_organisations_for :fatality_notice
  should_allow_attached_images_for :fatality_notice
  should_allow_role_appointments_for :fatality_notice
  should_prevent_modification_of_unmodifiable :fatality_notice
  should_allow_overriding_of_first_published_at_for :fatality_notice
  should_have_summary :fatality_notice
  should_allow_scheduled_publication_of :fatality_notice
  should_allow_access_limiting_of :fatality_notice

  view_test "show renders the summary" do
    draft_fatality_notice = create(:draft_fatality_notice, summary: "a-simple-summary")

    get :show, id: draft_fatality_notice

    assert_select ".summary", text: "a-simple-summary"
  end

  view_test "when creating allows assignment to operational field" do
    get :new

    assert_select "form#new_edition" do
      assert_select "select[name='edition[operational_field_id]']"
    end
  end

  view_test "when editing allows assignment to operational field" do
    field = create(:operational_field)
    edition = create(:fatality_notice, operational_field: field)

    get :edit, id: edition

    assert_select "form#edit_edition" do
      assert_select "select[name='edition[operational_field_id]']"
    end
  end

  view_test "shows assigned operational field" do
    field = create(:operational_field)
    edition = create(:fatality_notice, operational_field: field)

    get :show, id: edition

    assert_select "section", text: %r{#{field.name}}
  end

  view_test "should display fields for new fatality notice casualties" do
    get :new

    assert_select "textarea[name='edition[fatality_notice_casualties_attributes][0][personal_details]']"
  end

  test "creating should be able to create a new casualty for the fatality notice" do
    field = create(:operational_field)
    attributes = controller_attributes_for(:fatality_notice,
      operational_field_id: field.id,
      fatality_notice_casualties_attributes: {"0" =>{
        personal_details: "Personal details"
      }}
    )

    post :create, edition: attributes
    assert fatality_notice = FatalityNotice.last
    assert fatality_notice_casuality = fatality_notice.fatality_notice_casualties.last
    assert_equal "Personal details", fatality_notice_casuality.personal_details
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.merge(operational_field_id: create(:operational_field).id)
  end
end

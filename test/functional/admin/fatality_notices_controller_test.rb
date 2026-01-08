require "test_helper"
require "support/concerns/admin_edition_controller/summary_tests"
require "support/concerns/admin_edition_controller/creating_tests"
require "support/concerns/admin_edition_controller/edition_editing_tests"
require "support/concerns/admin_edition_controller/lead_and_supporting_organisations_tests"
require "support/concerns/admin_edition_controller/role_appointments_tests"
require "support/concerns/admin_edition_controller/first_published_at_overriding_tests"
require "support/concerns/admin_edition_controller/access_limiting_tests"
require "support/concerns/admin_edition_controller/govspeak_history_and_fact_checking_tabs_tests"

class Admin::FatalityNoticesControllerTest < ActionController::TestCase
  include AdminEditionController::FirstPublishedAtOverridingTests
  include AdminEditionController::AccessLimitingTests
  include AdminEditionController::GovspeakHistoryAndFactCheckingTabsTests

  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller
  should_require_fatality_handling_permission_to_access :fatality_notice, :new, :edit

  should_allow_scheduled_publication_of :fatality_notice

  view_test "show renders the summary" do
    draft_fatality_notice = create(:draft_fatality_notice, summary: "a-simple-summary")
    stub_publishing_api_expanded_links_with_taxons(draft_fatality_notice.content_id, [])

    get :show, params: { id: draft_fatality_notice }

    assert_select ".page-header .govuk-body-lead", text: "a-simple-summary"
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

    get :edit, params: { id: edition }

    assert_select "form#edit_edition" do
      assert_select "select[name='edition[operational_field_id]']"
    end
  end

  view_test "should display fields for new fatality notice casualties" do
    get :new

    assert_select "textarea[name='edition[fatality_notice_casualties_attributes][0][personal_details]']"
  end

  test "creating should be able to create a new casualty for the fatality notice" do
    field = create(:operational_field)
    attributes = controller_attributes_for(
      :fatality_notice,
      operational_field_id: field.id,
      fatality_notice_casualties_attributes: {
        "0" => {
          personal_details: "Personal details",
        },
      },
    )

    post :create, params: { edition: attributes }
    assert fatality_notice = FatalityNotice.last
    assert fatality_notice_casuality = fatality_notice.fatality_notice_casualties.last
    assert_equal "Personal details", fatality_notice_casuality.personal_details
  end

private

  def edition_type
    :fatality_notice
  end

  def controller_attributes_for(edition_type, attributes = {})
    super.merge(operational_field_id: create(:operational_field).id)
  end
end

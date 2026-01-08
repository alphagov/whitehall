require "test_helper"
require "support/concerns/admin_edition_controller/summary_tests"
require "support/concerns/admin_edition_controller/creating_tests"
require "support/concerns/admin_edition_controller/edition_editing_tests"
require "support/concerns/admin_edition_controller/worldwide_organisations_tests"
require "support/concerns/admin_edition_controller/govspeak_history_and_fact_checking_tabs_tests"

class Admin::CaseStudiesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  include AdminEditionController::SummaryTests
  include AdminEditionController::CreatingTests
  include AdminEditionController::EditionEditingTests
  include AdminEditionController::WorldwideOrganisationsTests
  include AdminEditionController::GovspeakHistoryAndFactCheckingTabsTests

  should_be_an_admin_controller

  should_allow_scheduled_publication_of :case_study
  should_allow_association_between_world_locations_and :case_study

  test "PATCH :update_image_display_option updates the image_display option and handles updating an editions lead image" do
    edition = create(:draft_case_study, image_display_option: "custom_image")
    image = create(:image, edition:)
    create(:edition_lead_image, edition:, image:)

    patch :update_image_display_option, params: { id: edition.id, edition: { image_display_option: "no_image" } }

    assert_equal "no_image", edition.reload.image_display_option
    assert_nil edition.lead_image
  end

private

  def edition_type
    :case_study
  end
end

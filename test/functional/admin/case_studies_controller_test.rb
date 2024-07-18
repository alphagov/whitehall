require "test_helper"

class Admin::CaseStudiesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  should_allow_creating_of :case_study
  should_allow_editing_of :case_study

  should_prevent_modification_of_unmodifiable :case_study
  should_have_summary :case_study
  should_allow_scheduled_publication_of :case_study
  should_allow_association_with_editionable_worldwide_organisations :case_study
  should_allow_association_between_world_locations_and :case_study
  should_send_drafts_to_content_preview_environment_for :case_study
  should_render_govspeak_history_and_fact_checking_tabs_for :case_study

  test "PATCH :update_image_display_option updates the image_display option and handles updating an editions lead image" do
    edition = create(:draft_case_study, image_display_option: "custom_image")
    image = create(:image, edition:)
    create(:edition_lead_image, edition:, image:)

    patch :update_image_display_option, params: { id: edition.id, edition: { image_display_option: "no_image" } }

    assert_equal "no_image", edition.reload.image_display_option
    assert_nil edition.lead_image
  end
end

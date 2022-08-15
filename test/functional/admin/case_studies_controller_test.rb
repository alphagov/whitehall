require "test_helper"

class Admin::CaseStudiesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  should_allow_creating_of :case_study
  should_allow_editing_of :case_study

  should_allow_attached_images_for :case_study
  should_prevent_modification_of_unmodifiable :case_study
  should_have_summary :case_study
  should_allow_scheduled_publication_of :case_study
  should_allow_setting_first_published_at_during_speed_tagging :case_study
  should_allow_association_with_worldwide_organisations :case_study
  should_allow_association_between_world_locations_and :case_study
  should_send_drafts_to_content_preview_environment_for :case_study

  view_test "case studies show image display options radio buttons" do
    get :new
    assert_select "form#new_edition" do
      assert_select "#edition_image_display_option_no_image"
      assert_select "#edition_image_display_option_organisation_image"
      assert_select "#edition_image_display_option_custom_image"
      assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text']"
      assert_select "textarea[name='edition[images_attributes][0][caption]']"
      assert_select "input[name='edition[images_attributes][0][image_data_attributes][file]'][type='file']"
    end
  end

  view_test "GET :show renders a side nav bar with notes, history and fact checking" do
    edition = create(:draft_case_study)
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    get :show, params: { id: edition }

    assert_select ".nav-tabs a", text: "Notes 0"
    assert_select ".nav-tabs a", text: "History 1"
  end

  view_test "GET :show editions renders links to history, notes and fact checking endpoints and no sidebar when user has `View move tabs to endpoints` permission" do
    @current_user.permissions << "View move tabs to endpoints"
    edition = create(:draft_case_study)
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    get :show, params: { id: edition }

    assert_select "a", text: "Notes", count: 1
    assert_select "a", text: "History", count: 1
    assert_select ".nav-tabs a", text: "Notes 0", count: 0
    assert_select ".nav-tabs a", text: "History 1", count: 0
  end

  view_test "GET :edit renders a side nav bar with notes, history and fact checking" do
    edition = create(:draft_case_study)

    get :edit, params: { id: edition }

    assert_select ".nav-tabs a", text: "Notes 0"
    assert_select ".nav-tabs a", text: "History 1"
  end
end

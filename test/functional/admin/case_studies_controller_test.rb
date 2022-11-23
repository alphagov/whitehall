require "test_helper"

class Admin::CaseStudiesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    @current_user.permissions << "Preview design system"
  end

  should_be_an_admin_controller

  should_allow_creating_of :case_study
  should_allow_editing_of :case_study

  should_allow_attached_images_for :case_study
  should_prevent_modification_of_unmodifiable :case_study
  should_have_summary :case_study
  should_allow_scheduled_publication_of :case_study
  should_allow_association_with_worldwide_organisations :case_study
  should_allow_association_between_world_locations_and :case_study
  should_send_drafts_to_content_preview_environment_for :case_study
  should_render_govspeak_history_and_fact_checking_tabs_for :case_study

  view_test "case studies show image display options radio buttons" do
    get :new
    assert_select "form#new_edition" do
      assert_select "input[type='radio'][name='edition[image_display_option]'][value='no_image']"
      assert_select "input[type='radio'][name='edition[image_display_option]'][value='organisation_image']"
      assert_select "input[type='radio'][name='edition[image_display_option]'][value='custom_image']"
      assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text']"
      assert_select "textarea[name='edition[images_attributes][0][caption]']"
      assert_select "input[name='edition[images_attributes][0][image_data_attributes][file]'][type='file']"
    end
  end
end

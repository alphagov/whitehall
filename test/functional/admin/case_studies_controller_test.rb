require 'test_helper'

class Admin::CaseStudiesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :case_study
  should_allow_creating_of :case_study
  should_allow_editing_of :case_study

  should_allow_related_policies_for :case_study
  should_allow_attached_images_for :case_study
  should_allow_video_for :case_study
  should_be_rejectable :case_study
  should_be_publishable :case_study
  should_be_force_publishable :case_study
  should_be_able_to_delete_an_edition :case_study
  should_link_to_public_version_when_published :case_study
  should_not_link_to_public_version_when_not_published :case_study
  should_prevent_modification_of_unmodifiable :case_study
  should_have_summary :case_study

end

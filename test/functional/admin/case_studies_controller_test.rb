require 'test_helper'

class Admin::CaseStudiesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_creating_of :case_study
  should_allow_editing_of :case_study

  should_allow_related_policies_for :case_study
  should_allow_attached_images_for :case_study
  should_prevent_modification_of_unmodifiable :case_study
  should_have_summary :case_study
  should_allow_assignment_to_document_series :case_study
  should_allow_scheduled_publication_of :case_study

end

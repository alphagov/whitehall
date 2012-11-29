require 'test_helper'

class Admin::FatalityNoticesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :fatality_notice
  should_allow_creating_of :fatality_notice
  should_allow_editing_of :fatality_notice

  should_show_document_audit_trail_for :fatality_notice, :show
  should_show_document_audit_trail_for :fatality_notice, :edit

  should_allow_organisations_for :fatality_notice
  should_allow_attached_images_for :fatality_notice
  should_be_rejectable :fatality_notice
  should_be_publishable :fatality_notice
  should_be_force_publishable :fatality_notice
  should_be_able_to_delete_an_edition :fatality_notice
  should_link_to_public_version_when_published :fatality_notice
  should_not_link_to_public_version_when_not_published :fatality_notice
  should_link_to_preview_version_when_not_published :fatality_notice
  should_prevent_modification_of_unmodifiable :fatality_notice
  should_allow_overriding_of_first_published_at_for :fatality_notice
  should_have_summary :fatality_notice
  should_allow_scheduled_publication_of :fatality_notice

  test "show renders the summary" do
    draft_fatality_notice = create(:draft_fatality_notice, summary: "a-simple-summary")

    get :show, id: draft_fatality_notice

    assert_select ".summary", text: "a-simple-summary"
  end
end

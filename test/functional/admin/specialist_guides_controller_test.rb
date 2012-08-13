require 'test_helper'

class Admin::SpecialistGuidesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :specialist_guide
  should_allow_creating_of :specialist_guide
  should_allow_editing_of :specialist_guide
  should_allow_revision_of :specialist_guide

  should_show_document_audit_trail_for :specialist_guide, :show
  should_show_document_audit_trail_for :specialist_guide, :edit

  should_allow_organisations_for :specialist_guide
  should_allow_association_with_topics :specialist_guide
  should_allow_attachments_for :specialist_guide
  should_show_inline_attachment_help_for :specialist_guide
  should_allow_attached_images_for :specialist_guide
  should_not_use_lead_image_for :specialist_guide
  should_be_rejectable :specialist_guide
  should_be_publishable :specialist_guide
  should_be_force_publishable :specialist_guide
  should_be_able_to_delete_an_edition :specialist_guide
  should_link_to_public_version_when_published :specialist_guide
  should_not_link_to_public_version_when_not_published :specialist_guide
  should_prevent_modification_of_unmodifiable :specialist_guide
  should_allow_association_with_related_mainstream_content :specialist_guide
  should_allow_alternative_format_provider_for :specialist_guide
end

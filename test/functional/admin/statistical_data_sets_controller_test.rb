require 'test_helper'

class Admin::StatisticalDataSetsControllerTest < ActionController::TestCase
  setup do
    StatisticalDataSet.stubs(access_limited_by_default?: false)
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :statistical_data_set
  should_allow_creating_of :statistical_data_set
  should_allow_editing_of :statistical_data_set
  should_allow_revision_of :statistical_data_set

  should_show_document_audit_trail_for :statistical_data_set, :show
  should_show_document_audit_trail_for :statistical_data_set, :edit

  should_allow_organisations_for :statistical_data_set
  should_allow_attachments_for :statistical_data_set
  should_allow_bulk_upload_attachments_for :statistical_data_set
  should_require_alternative_format_provider_for :statistical_data_set
  show_should_display_attachments_for :statistical_data_set
  should_allow_attachment_references_for :statistical_data_set
  should_show_inline_attachment_help_for :statistical_data_set
  should_be_rejectable :statistical_data_set
  should_be_publishable :statistical_data_set
  should_allow_unpublishing_for :statistical_data_set
  should_be_force_publishable :statistical_data_set
  should_be_able_to_delete_an_edition :statistical_data_set
  should_link_to_public_version_when_published :statistical_data_set
  should_not_link_to_public_version_when_not_published :statistical_data_set
  should_link_to_preview_version_when_not_published :statistical_data_set
  should_prevent_modification_of_unmodifiable :statistical_data_set
  should_allow_alternative_format_provider_for :statistical_data_set
  should_allow_assignment_to_document_series :statistical_data_set
  should_allow_scheduled_publication_of :statistical_data_set
  should_allow_access_limiting_of :statistical_data_set

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end

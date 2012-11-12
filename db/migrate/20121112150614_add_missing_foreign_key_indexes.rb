class AddMissingForeignKeyIndexes < ActiveRecord::Migration
  def change
    add_index :attachment_sources, :attachment_id
    add_index :attachments, :attachment_data_id
    add_index :consultation_participations, :edition_id
    add_index :consultation_participations, :consultation_response_form_id, name: :index_cons_participations_on_cons_response_form_id
    add_index :consultation_response_attachments, :response_id
    add_index :consultation_response_attachments, :attachment_id
    add_index :document_series, :organisation_id
    add_index :document_sources, :document_id
    add_index :edition_mainstream_categories, :edition_id
    add_index :edition_mainstream_categories, :mainstream_category_id
    add_index :edition_organisations, :edition_organisation_image_data_id, name: :index_edition_orgs_on_edition_org_image_data_id
    add_index :edition_role_appointments, :edition_id
    add_index :edition_role_appointments, :role_appointment_id
    add_index :edition_statistical_data_sets, :edition_id
    add_index :edition_statistical_data_sets, :document_id
    add_index :editions, :policy_team_id
    add_index :editions, :publication_type_id
    add_index :editions, :alternative_format_provider_id
    add_index :editions, :document_series_id
    add_index :editions, :primary_mainstream_category_id
    add_index :organisations, :organisation_logo_type_id
    add_index :responses, :edition_id
  end
end

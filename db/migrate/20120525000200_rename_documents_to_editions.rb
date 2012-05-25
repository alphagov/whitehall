class RenameDocumentsToEditions < ActiveRecord::Migration

  FOREIGN_KEYS_ON_DOCUMENTS = [
    :consultation_doc_identity_id,
    :doc_identity_id,
    :role_appointment_id,
    :speech_type_id
  ].freeze

  TABLES_WITH_DOCUMENT_ID = [
    :document_attachments,
    :document_authors,
    :document_countries,
    :document_ministerial_roles,
    :document_relations,
    :editorial_remarks,
    :fact_check_requests,
    :images,
    :nation_inapplicabilities,
    :supporting_pages,
  ].freeze

  def change
    FOREIGN_KEYS_ON_DOCUMENTS.each { |key| remove_index :documents, key }
    rename_table :documents, :editions
    FOREIGN_KEYS_ON_DOCUMENTS.each { |key| add_index :editions, key }

    TABLES_WITH_DOCUMENT_ID.each do |table|
      remove_index table, :document_id
      rename_column table, :document_id, :edition_id
      add_index table, :edition_id
    end

    remove_index :recent_document_openings, [:document_id, :editor_id]
    rename_column :recent_document_openings, :document_id, :edition_id
    add_index :recent_document_openings, [:edition_id, :editor_id], unique: true

    remove_index :document_organisations, [:document_id, :organisation_id]
    rename_column :document_organisations, :document_id, :edition_id
    add_index :document_organisations, [:edition_id, :organisation_id], unique: true
  end
end

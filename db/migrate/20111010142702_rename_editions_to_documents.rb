class RenameEditionsToDocuments < ActiveRecord::Migration
  def change
    rename_table :editions, :documents
    rename_table :edition_topics, :document_topics
    rename_column :document_topics, :edition_id, :document_id
    rename_table :edition_roles, :document_roles
    rename_column :document_roles, :edition_id, :document_id
    rename_table :edition_organisations, :document_organisations
    rename_column :document_organisations, :edition_id, :document_id
    rename_column :fact_check_requests, :edition_id, :document_id
  end
end

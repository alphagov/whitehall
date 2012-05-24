class RenameRecentDocumentOpeningsToRecentEditionOpenings < ActiveRecord::Migration
  def change
    remove_index :recent_document_openings, name: :index_recent_document_openings_on_edition_id_and_editor_id
    rename_table :recent_document_openings, :recent_edition_openings
    add_index :recent_edition_openings, [:edition_id, :editor_id], unique: true
  end
end

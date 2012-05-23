class RenameDocumentAuthorsToEditionAuthors < ActiveRecord::Migration
  def change
    remove_index :document_authors, :edition_id
    remove_index :document_authors, :user_id

    rename_table :document_authors, :edition_authors

    add_index :edition_authors, :edition_id
    add_index :edition_authors, :user_id
  end
end
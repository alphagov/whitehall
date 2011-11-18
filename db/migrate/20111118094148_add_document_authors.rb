class AddDocumentAuthors < ActiveRecord::Migration
  def change
    create_table :document_authors, force: true do |t|
      t.references :document
      t.references :user
      t.timestamps
    end

    insert %{
      INSERT INTO document_authors (document_id, user_id, created_at, updated_at)
      SELECT id, author_id, created_at, created_at
      FROM documents
    }

    remove_column :documents, :author_id
  end
end
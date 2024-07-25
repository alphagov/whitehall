class RenameContentBlockRelations < ActiveRecord::Migration[7.1]
  def change
    rename_column :content_block_edition_authors, :content_block_edition_id, :edition_id
    rename_column :content_block_editions, :content_block_document_id, :document_id
  end
end

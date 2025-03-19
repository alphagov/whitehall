class AddDeletedAtToContentBlocks < ActiveRecord::Migration[8.0]
  def change
    add_column :content_block_documents, :deleted_at, :datetime, default: nil
  end
end

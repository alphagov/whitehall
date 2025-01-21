class AddInternalChangeNoteToContentBlockEditions < ActiveRecord::Migration[7.1]
  def change
    add_column :content_block_editions, :internal_change_note, :string
  end
end

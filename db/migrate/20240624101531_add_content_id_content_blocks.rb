class AddContentIdContentBlocks < ActiveRecord::Migration[7.1]
  def change
    add_column :content_blocks, :content_id, :string
  end
end

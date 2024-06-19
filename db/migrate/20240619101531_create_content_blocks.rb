class CreateContentBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :content_blocks do |t|
      t.string :title
      t.string :block_type
      t.json :properties
      t.timestamps
    end
  end
end

class CreateContentBlockEditions < ActiveRecord::Migration[7.1]
  def change
    create_table :content_block_editions do |t|
      t.string :content_id
      t.string :title
      t.string :block_type
      t.json :properties
      t.references :content_block_document, index: true, foreign_key: true
      t.datetime "created_at", precision: nil
    end
  end
end

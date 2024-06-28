class CreateContentBlockEditions < ActiveRecord::Migration[7.1]
  def change
    create_table :content_block_editions do |t|
      t.json :details, null: false
      t.references :content_block_document, index: true, foreign_key: true, null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end
  end
end

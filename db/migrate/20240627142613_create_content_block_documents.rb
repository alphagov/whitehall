class CreateContentBlockDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :content_block_documents do |t|
      t.string :content_id
      t.string :title
      t.string :block_type
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
    end
  end
end

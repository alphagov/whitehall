class CreateContentBlockEditionAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :content_block_edition_authors do |t|
      t.references :user, index: true, null: false
      t.references :content_block_edition, index: true, foreign_key: true, null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end
  end
end

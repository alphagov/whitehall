class CreateContentBlockEditionOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :content_block_edition_organisations do |t|
      t.references :content_block_edition, index: true, foreign_key: true, null: false
      t.integer :organisation_id, index: true, null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end
  end
end

class CreateUnpublishings < ActiveRecord::Migration
  def change
    create_table :unpublishings do |t|
      t.references :edition
      t.references :unpublishing_reason
      t.text :explanation
      t.text :alternative_url

      t.timestamps
    end

    add_index :unpublishings, :edition_id
    add_index :unpublishings, :unpublishing_reason_id
  end
end

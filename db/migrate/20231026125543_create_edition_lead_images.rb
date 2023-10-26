class CreateEditionLeadImages < ActiveRecord::Migration[7.0]
  def change
    create_table :edition_lead_images do |t|
      t.integer "edition_id", foreign_key: true
      t.integer "image_id", foreign_key: true
      t.index %w[edition_id], name: "index_lead_image_on_edition_id", unique: true
      t.index %w[image_id], name: "index_lead_image_on_image_id"

      t.timestamps
    end
  end
end

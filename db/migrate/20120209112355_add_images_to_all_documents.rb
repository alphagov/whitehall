class AddImagesToAllDocuments < ActiveRecord::Migration
  def change
    create_table :image_data, force: true do |t|
      t.string :carrierwave_image
      t.timestamps
    end
    create_table :images, force: true do |t|
      t.references :image_data
      t.references :document
      t.string :alt_text
      t.text :caption
      t.timestamps
    end
  end
end
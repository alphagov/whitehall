class CreateFeaturedDocumentImages < ActiveRecord::Migration
  def change
    add_column :documents, :featured_document_image_id, :integer
    create_table :featured_document_images, force: true do |t|
      t.string :carrierwave_image
      t.timestamps
    end
  end
end

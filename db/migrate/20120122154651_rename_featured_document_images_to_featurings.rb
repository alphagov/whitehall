class RenameFeaturedDocumentImagesToFeaturings < ActiveRecord::Migration
  def change
    rename_table :featured_document_images, :featurings
    rename_column :documents, :featured_document_image_id, :featuring_id
  end
end

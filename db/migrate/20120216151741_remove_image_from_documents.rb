class RemoveImageFromDocuments < ActiveRecord::Migration
  def change
    remove_column :documents, :carrierwave_image
    remove_column :documents, :image_alt_text
    remove_column :documents, :image_caption
  end
end

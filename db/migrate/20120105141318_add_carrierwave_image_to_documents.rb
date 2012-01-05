class AddCarrierwaveImageToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :carrierwave_image, :string
  end
end

class AddImageDataToClassifications < ActiveRecord::Migration
  def change
    add_column :classifications, :carrierwave_image, :string
    add_column :classifications, :logo_alt_text, :string
  end
end

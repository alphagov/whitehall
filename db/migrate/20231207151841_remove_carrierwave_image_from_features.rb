class RemoveCarrierwaveImageFromFeatures < ActiveRecord::Migration[7.0]
  def change
    remove_column :features, :carrierwave_image, :string
  end
end

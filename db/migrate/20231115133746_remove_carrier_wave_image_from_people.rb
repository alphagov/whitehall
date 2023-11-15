class RemoveCarrierWaveImageFromPeople < ActiveRecord::Migration[7.0]
  def change
    remove_column :people, :carrierwave_image, :string
  end
end

class RemoveCarrierwaveImageFromTakePartPages < ActiveRecord::Migration[7.0]
  def change
    remove_column :take_part_pages, :carrierwave_image, :string
  end
end

class AddReplaceIdToImageData < ActiveRecord::Migration[8.0]
  def change
    add_column :image_data, :replaced_by_id, :integer
  end
end

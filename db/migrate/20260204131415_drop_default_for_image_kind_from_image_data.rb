class DropDefaultForImageKindFromImageData < ActiveRecord::Migration[8.0]
  def change
    change_column_default :image_data, :image_kind, from: "default", to: nil
  end
end

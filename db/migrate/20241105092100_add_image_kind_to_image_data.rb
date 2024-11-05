class AddImageKindToImageData < ActiveRecord::Migration[7.1]
  def change
    add_column :image_data, :image_kind, :string, default: "default", null: false
  end
end

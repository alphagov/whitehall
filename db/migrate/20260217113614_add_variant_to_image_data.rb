class AddVariantToImageData < ActiveRecord::Migration[8.1]
  def change
    add_column :image_data, :variant, :string
  end
end

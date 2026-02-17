class AddImageRefToImageData < ActiveRecord::Migration[8.1]
  def change
    add_reference :image_data, :image, foreign_key: true, type: :integer
  end
end

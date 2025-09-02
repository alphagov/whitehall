class AddFieldsToImageData < ActiveRecord::Migration[8.0]
  def change
    change_table :image_data, bulk: true do |t|
      t.json "dimensions"
      t.json "crop_data"
    end
  end
end

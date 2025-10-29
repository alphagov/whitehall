class AddFieldsToImageData < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      change_table :image_data, bulk: true do |t|
        t.json :crop_data
        t.json :dimensions
        t.integer :replaced_by_id
        t.index :replaced_by_id
      end
    end
  end
end

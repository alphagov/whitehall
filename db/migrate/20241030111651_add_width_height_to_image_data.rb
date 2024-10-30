class AddWidthHeightToImageData < ActiveRecord::Migration[7.1]
  def change
    change_table(:image_data, bulk: true) do |t|
      t.column :valid_width, :integer, default: 960
      t.column :valid_height, :integer, default: 640
    end
  end
end

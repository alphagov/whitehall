class AddImageDisplayOptionToEditions < ActiveRecord::Migration[5.1]
  def change
    add_column :editions, :image_display_option, :string
  end

  def down
    remove_column :editions, :image_display_option, :string
  end
end

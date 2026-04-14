class AddSlugFromTitleToEditions < ActiveRecord::Migration[8.1]
  def change
    add_column :editions, :slug_from_title, :string
  end
end

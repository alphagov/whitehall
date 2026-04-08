class AddSlugOverrideToEditions < ActiveRecord::Migration[8.1]
  def change
    add_column :editions, :slug_override, :string
  end
end

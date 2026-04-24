class AddIndexToEditionsSlugOverride < ActiveRecord::Migration[8.1]
  def change
    add_index :editions, :slug_override
  end
end

class AddIndexToEditionUpdatedAt < ActiveRecord::Migration[5.1]
  def change
    add_index :editions, :updated_at
  end
end

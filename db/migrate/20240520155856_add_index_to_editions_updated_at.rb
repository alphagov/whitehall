class AddIndexToEditionsUpdatedAt < ActiveRecord::Migration[7.1]
  def change
    add_index(:editions, :updated_at)
  end
end

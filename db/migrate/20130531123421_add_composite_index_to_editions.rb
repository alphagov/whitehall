class AddCompositeIndexToEditions < ActiveRecord::Migration
  def change
    add_index :editions, [:state, :type]
  end
end

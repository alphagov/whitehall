class RemoveFeaturedColumnFromEdition < ActiveRecord::Migration
  def up
    remove_column :editions, :featured
  end

  def down
    add_column :editions, :featured
  end
end

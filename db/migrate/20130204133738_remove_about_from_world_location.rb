class RemoveAboutFromWorldLocation < ActiveRecord::Migration
  def up
    remove_column :world_locations, :about
  end

  def down
    add_column :world_locations, :about, :string
  end
end

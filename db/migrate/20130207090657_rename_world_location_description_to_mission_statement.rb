class RenameWorldLocationDescriptionToMissionStatement < ActiveRecord::Migration
  def change
    rename_column :world_locations, :description, :mission_statement
  end
end

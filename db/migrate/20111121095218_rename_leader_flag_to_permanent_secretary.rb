class RenameLeaderFlagToPermanentSecretary < ActiveRecord::Migration
  def change
    rename_column :roles, :leader, :permanent_secretary
  end
end
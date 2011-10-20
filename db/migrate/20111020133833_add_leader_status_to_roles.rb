class AddLeaderStatusToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :leader, :boolean, default: false
  end
end

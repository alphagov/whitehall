class DropDefaultRoleType < ActiveRecord::Migration
  def change
    change_column_default("roles", "type", nil)
  end
end

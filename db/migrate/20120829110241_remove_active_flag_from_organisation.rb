class RemoveActiveFlagFromOrganisation < ActiveRecord::Migration
  def up
    remove_column :organisations, :active
  end

  def down
    add_column :organisations, :active, :boolean, default: false, null: false
  end
end

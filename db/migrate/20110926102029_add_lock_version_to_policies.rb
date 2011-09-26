class AddLockVersionToPolicies < ActiveRecord::Migration
  def change
    add_column :policies, :lock_version, :integer, :default => 0
  end
end

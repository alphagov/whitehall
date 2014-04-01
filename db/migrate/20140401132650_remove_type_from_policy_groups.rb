class RemoveTypeFromPolicyGroups < ActiveRecord::Migration
  def up
    remove_column :policy_groups, :type
  end
end

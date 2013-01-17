class AddPolicyAdvisoryFieldsToPolicyGroups < ActiveRecord::Migration
  def change
    add_column :policy_groups, :summary, :text
  end
end

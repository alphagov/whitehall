class CreateEditionPolicyGroups < ActiveRecord::Migration
  def change
    create_table :edition_policy_groups, force: true do |t|
      t.references :edition
      t.references :policy_group
    end

    execute "INSERT INTO edition_policy_groups (edition_id, policy_group_id) SELECT id, policy_group_id FROM editions WHERE policy_group_id IS NOT NULL"

    remove_column :editions, :policy_group_id
  end
end

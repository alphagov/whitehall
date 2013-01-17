class RenamePolicyTeamsToPolicyGroups < ActiveRecord::Migration
  def change
    rename_table :policy_teams, :policy_groups
    rename_index :editions, "index_editions_on_policy_team_id", "index_editions_on_policy_group_id"

    add_column :policy_groups, :type, :string

    # This data change is irreversible
    execute "UPDATE policy_groups SET type='PolicyTeam'"

    rename_column :editions, :policy_team_id, :policy_group_id
  end
end

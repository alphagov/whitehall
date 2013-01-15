class RenamePolicyTeamsToPolicyGroups < ActiveRecord::Migration
  def up
    rename_table :policy_teams, :policy_groups
    rename_index :editions, "index_editions_on_policy_team_id", "index_editions_on_policy_group_id"

    add_column :policy_groups, :type, :string
    execute "UPDATE policy_groups SET type='PolicyTeam'"

    rename_column :editions, :policy_team_id, :policy_group_id
  end

  def down
    rename_column :editions, :policy_group_id, :policy_team_id

    remove_column :policy_groups, :type

    rename_index :editions, "index_editions_on_policy_group_id", "index_editions_on_policy_team_id"
    rename_table :policy_groups, :policy_teams
  end
end

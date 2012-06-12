class CreatePolicyTeams < ActiveRecord::Migration
  def change
    create_table :policy_teams, force: true do |t|
      t.string :email
      t.timestamps
    end
    add_column :editions, :policy_team_id, :integer
  end
end

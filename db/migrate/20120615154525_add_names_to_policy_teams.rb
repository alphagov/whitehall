class AddNamesToPolicyTeams < ActiveRecord::Migration
  def change
    add_column :policy_teams, :name, :string
  end
end
class AddDescriptionToPolicyTeams < ActiveRecord::Migration
  def change
    add_column :policy_teams, :description, :text
  end
end

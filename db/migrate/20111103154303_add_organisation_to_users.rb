class AddOrganisationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :organisation_id, :integer
  end
end

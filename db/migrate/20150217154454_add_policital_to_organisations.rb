class AddPolicitalToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :political, :boolean, default: false
  end
end

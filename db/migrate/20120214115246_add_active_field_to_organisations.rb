class AddActiveFieldToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :active, :boolean, null: false, default: false
  end
end

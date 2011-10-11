class RolesCanBelongToMultipleOrganisations < ActiveRecord::Migration
  def change
    create_table :organisation_roles, force: true do |t|
      t.references :organisation
      t.references :role
      t.timestamps
    end
    remove_column :roles, :organisation_id
  end
end

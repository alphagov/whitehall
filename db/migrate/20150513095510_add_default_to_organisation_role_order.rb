class AddDefaultToOrganisationRoleOrder < ActiveRecord::Migration
  def change
    change_column :organisation_roles, :ordering, :integer, default: 99
  end
end

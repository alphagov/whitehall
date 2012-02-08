class AddOrderingToOrganisationRoles < ActiveRecord::Migration
  def change
    add_column :organisation_roles, :ordering, :integer
  end
end
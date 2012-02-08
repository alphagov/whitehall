class RemoveOrphanOrganisationRoles < ActiveRecord::Migration
  def up
    delete "DELETE FROM organisation_roles WHERE role_id NOT IN (SELECT id FROM roles)"
  end

  def down
    # Intentionally blank
  end
end

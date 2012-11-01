class RemoveUseSingleIdentityBrandingFromOrganisations < ActiveRecord::Migration
  def up
    remove_column :organisations, :use_single_identity_branding
  end
  def down
    add_column :organisations, :use_single_identity_branding, :boolean, default: true
  end
end

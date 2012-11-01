class RemoveUseSingleIdentityBrandingFromOrganisations < ActiveRecord::Migration
  def change
    remove_column :organisations, :use_single_identity_branding
  end
end

class AddUseSingleIdentityFlagToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :use_single_identity_branding, :boolean, default: true
  end
end

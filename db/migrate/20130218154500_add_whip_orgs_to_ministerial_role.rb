class AddWhipOrgsToMinisterialRole < ActiveRecord::Migration
  def change
    add_column :roles, :whip_organisation_id, :integer
  end
end

class DeleteEditionMinisterialRole < ActiveRecord::Migration
  def change
    drop_table :edition_ministerial_roles
  end
end

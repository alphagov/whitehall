class AddCompositeIndexToOrganisations < ActiveRecord::Migration
  def change
    add_index :organisations, [:id, :organisation_type_id]
  end
end

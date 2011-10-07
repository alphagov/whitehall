class AssociateMinistersWithOrganisations < ActiveRecord::Migration
  def change
    add_column :ministers, :organisation_id, :integer
  end
end

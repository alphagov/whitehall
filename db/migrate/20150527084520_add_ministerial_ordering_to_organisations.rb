class AddMinisterialOrderingToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :ministerial_ordering, :integer
  end
end

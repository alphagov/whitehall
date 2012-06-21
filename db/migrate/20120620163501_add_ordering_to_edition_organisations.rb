class AddOrderingToEditionOrganisations < ActiveRecord::Migration
  def change
    add_column :edition_organisations, :ordering, :integer
  end
end
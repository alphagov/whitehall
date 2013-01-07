class AddLeadAndLeadOrderingToEditionOrganisations < ActiveRecord::Migration
  def change
    add_column :edition_organisations, :lead, :boolean, null: false, default: false
    add_column :edition_organisations, :lead_ordering, :integer
  end
end

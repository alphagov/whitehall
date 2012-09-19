class AddAltTextToEditionOrganisations < ActiveRecord::Migration
  def change
    add_column :edition_organisations, :alt_text, :string
  end
end
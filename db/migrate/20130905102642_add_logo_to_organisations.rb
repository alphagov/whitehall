class AddLogoToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :logo, :string
  end
end

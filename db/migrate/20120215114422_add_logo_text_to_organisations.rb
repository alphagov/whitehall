class AddLogoTextToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :logo_formatted_name, :text
  end
end
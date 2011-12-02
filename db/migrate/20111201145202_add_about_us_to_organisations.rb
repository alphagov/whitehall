class AddAboutUsToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :about_us, :text
  end
end

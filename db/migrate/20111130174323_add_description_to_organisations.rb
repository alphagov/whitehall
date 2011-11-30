class AddDescriptionToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :description, :text
  end
end
class AddDescriptionToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :description, :text, after: :slug
  end
end

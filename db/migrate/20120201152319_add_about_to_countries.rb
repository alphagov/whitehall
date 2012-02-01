class AddAboutToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :about, :text
  end
end

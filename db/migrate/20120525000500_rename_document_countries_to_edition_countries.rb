class RenameDocumentCountriesToEditionCountries < ActiveRecord::Migration
  def change
    remove_index :document_countries, :edition_id
    remove_index :document_countries, :country_id

    rename_table :document_countries, :edition_countries

    add_index :edition_countries, :edition_id
    add_index :edition_countries, :country_id
  end
end
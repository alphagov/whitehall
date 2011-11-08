class CreateDocumentCountries < ActiveRecord::Migration
  def change
    create_table :document_countries, force: true do |t|
      t.references :document
      t.references :country
      t.timestamps
    end
  end
end
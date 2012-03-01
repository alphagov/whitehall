class AddFeaturedToDocumentCountriesRelation < ActiveRecord::Migration
  def change
    add_column :document_countries, :featured, :boolean, default: false
  end
end

class PopulateDocumentIdentitySlugs < ActiveRecord::Migration
  def change
    update "UPDATE document_identities SET `slug` = `key`;"
  end
end

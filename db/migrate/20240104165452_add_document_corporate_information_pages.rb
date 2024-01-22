class AddDocumentCorporateInformationPages < ActiveRecord::Migration[7.1]
  def change
    create_table :document_corporate_information_pages do |t|
      t.integer :owning_document_id
      t.integer :edition_id
      t.timestamps

      t.index :owning_document_id, name: "index_document_corporate_information_pages_on_owning_document_id"
      t.index :edition_id, name: "index_document_corporate_information_pages_on_edition_id"
    end
  end
end

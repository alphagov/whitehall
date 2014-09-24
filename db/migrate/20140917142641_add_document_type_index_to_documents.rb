class AddDocumentTypeIndexToDocuments < ActiveRecord::Migration
  def change
    add_index :documents, :document_type
  end
end

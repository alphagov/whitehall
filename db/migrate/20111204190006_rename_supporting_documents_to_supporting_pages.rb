class RenameSupportingDocumentsToSupportingPages < ActiveRecord::Migration
  def change
    rename_table :supporting_documents, :supporting_pages
  end
end
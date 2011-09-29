class RenamePoliciesToDocuments < ActiveRecord::Migration
  def change
    rename_table :policies, :documents
    rename_column :editions, :policy_id, :document_id
  end
end

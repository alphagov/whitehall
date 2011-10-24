class RemoveKeyFromDocumentIdentities < ActiveRecord::Migration
  def change
    remove_column :document_identities, :key
  end
end

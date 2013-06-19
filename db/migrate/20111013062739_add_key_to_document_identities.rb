class AddKeyToDocumentIdentities < ActiveRecord::Migration
  class DocumentIdentityTable < ActiveRecord::Base
    include Whitehall::RandomKey
    self.table_name = "document_identities"
  end

  def change
    add_column :document_identities, :key, :string, limit: 8
    add_index :document_identities, :key, unique: true
    DocumentIdentityTable.all.each do |di|
      di.update_attributes(key: DocumentIdentityTable.unique_random_key)
    end
  end
end

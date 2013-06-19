class CorrectlyAddKeyToDocumentIdentities < ActiveRecord::Migration
  class DocumentIdentityTable < ActiveRecord::Base
    include Whitehall::RandomKey
    self.table_name = "document_identities"

    def key=(k)
      write_attribute(:key, k)
    end
  end

  def change
    DocumentIdentityTable.all.each do |di|
      if di.key.nil?
        di.update_attributes!(key: DocumentIdentityTable.unique_random_key)
      end
    end
  end
end

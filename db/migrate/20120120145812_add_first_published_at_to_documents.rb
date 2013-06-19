class AddFirstPublishedAtToDocuments < ActiveRecord::Migration
  class DocumentTable < ActiveRecord::Base
    self.table_name = "documents"
  end

  def change
    add_column :documents, :first_published_at, :datetime, after: :published_at

    DocumentTable.reset_column_information

    DocumentTable.record_timestamps = false
    DocumentTable.all.each do |document|
      document.update_attribute :first_published_at, document.document_identity.documents.minimum(:published_at)
    end
    DocumentTable.record_timestamps = true
  end
end

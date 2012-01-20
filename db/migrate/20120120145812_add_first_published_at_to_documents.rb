class AddFirstPublishedAtToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :first_published_at, :datetime, after: :published_at

    Document.reset_column_information

    Document.record_timestamps = false
    Document.all.each do |document|
      document.update_attribute :first_published_at, document.document_identity.documents.minimum(:published_at)
    end
    Document.record_timestamps = true
  end
end

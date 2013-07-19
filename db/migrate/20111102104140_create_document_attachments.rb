class CreateDocumentAttachments < ActiveRecord::Migration
  class DocumentTable < ActiveRecord::Base
    self.table_name = "documents"
  end

  def up
    create_table :document_attachments do |t|
      t.integer :document_id
      t.integer :attachment_id

      t.timestamps
    end
    DocumentTable.where("attachment_id IS NOT NULL").each do |document|
      DocumentAttachment.create!(document_id: document.id, attachment_id: document.attachment_id)
    end
    remove_column :documents, :attachment_id
  end

  def down
    add_column :documents, :attachment_id, :integer
    DocumentAttachment.each do |document_attachment|
      document = DocumentTable.find(document_attachment.document_id)
      document.update_column(:attachment_id, document_attachment.attachment_id)
    end
    drop_table :document_attachment
  end
end
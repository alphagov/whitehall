class RenameDocumentAttachmentsToEditionAttachments < ActiveRecord::Migration
  def change
    remove_index :document_attachments, :attachment_id
    remove_index :document_attachments, :edition_id

    rename_table :document_attachments, :edition_attachments

    add_index :edition_attachments, :attachment_id
    add_index :edition_attachments, :edition_id
  end
end
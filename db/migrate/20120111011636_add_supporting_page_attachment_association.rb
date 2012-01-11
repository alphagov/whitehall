class AddSupportingPageAttachmentAssociation < ActiveRecord::Migration
  def change
    create_table :supporting_page_attachments, force: true do |t|
      t.integer :supporting_page_id
      t.integer :attachment_id
      t.timestamps
    end
  end
end
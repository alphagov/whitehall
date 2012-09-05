class AddConsultationResponseAttachments < ActiveRecord::Migration
  def up
    create_table :consultation_response_attachments, force: true do |t|
      t.integer :response_id
      t.integer :attachment_id
      t.timestamps
    end
  end

  def down
    drop_table :consultation_response_attachments
  end
end

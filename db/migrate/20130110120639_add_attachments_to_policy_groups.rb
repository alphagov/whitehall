class AddAttachmentsToPolicyGroups < ActiveRecord::Migration
  def change
    create_table :policy_group_attachments, force: true do |t|
      t.integer :policy_group_id
      t.integer :attachment_id
      t.timestamps
    end
  end
end

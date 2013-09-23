class DropAttachmentJoinModels < ActiveRecord::Migration
  def up
    drop_table :consultation_response_attachments
    drop_table :corporate_information_page_attachments
    drop_table :edition_attachments
    drop_table :policy_group_attachments
    drop_table :supporting_page_attachments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

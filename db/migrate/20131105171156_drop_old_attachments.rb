class DropOldAttachments < ActiveRecord::Migration
  def change
    drop_table :old_attachments
  end
end

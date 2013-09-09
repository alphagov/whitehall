class AddTypeToAttachments < ActiveRecord::Migration
  def up
    add_column :attachments, :type, :string

    execute "UPDATE attachments SET type = 'FileAttachment' WHERE type IS NULL"
  end

  def down
    remove_column :attachments, :type
  end
end

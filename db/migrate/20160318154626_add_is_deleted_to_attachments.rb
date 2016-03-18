class AddIsDeletedToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :deleted, :boolean, null: false, default: false
  end
end

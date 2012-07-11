class AddAccessibleFlagToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :accessible, :boolean
  end
end

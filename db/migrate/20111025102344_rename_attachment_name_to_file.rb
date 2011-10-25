class RenameAttachmentNameToFile < ActiveRecord::Migration
  def change
    rename_column :attachments, :name, :file
  end
end

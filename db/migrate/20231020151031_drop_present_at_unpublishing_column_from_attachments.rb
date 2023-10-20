class DropPresentAtUnpublishingColumnFromAttachments < ActiveRecord::Migration[7.0]
  def change
    remove_column :attachment_data, :present_at_unpublish, :boolean, if_exists: true
  end
end

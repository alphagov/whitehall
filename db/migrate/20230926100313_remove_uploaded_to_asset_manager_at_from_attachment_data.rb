class RemoveUploadedToAssetManagerAtFromAttachmentData < ActiveRecord::Migration[7.0]
  def change
    remove_column :attachment_data, :uploaded_to_asset_manager_at, :datetime, if_exists: true
  end
end

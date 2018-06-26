class AddUploadedToAssetManagerAtTimeToAttachmentData < ActiveRecord::Migration[5.0]
  def up
    add_column :attachment_data, :uploaded_to_asset_manager_at, :datetime
    AttachmentData.reset_column_information
    AttachmentData.update_all(uploaded_to_asset_manager_at: Time.zone.now)
  end

  def down
    remove_column :attachment_data, :uploaded_to_asset_manager_at
  end
end

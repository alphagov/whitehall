class AddSynchronisedWithAssetManagerAtTimeToAttachmentData < ActiveRecord::Migration[5.0]
  def change
    add_column :attachment_data, :synchronised_with_asset_manager_at, :datetime
  end
end

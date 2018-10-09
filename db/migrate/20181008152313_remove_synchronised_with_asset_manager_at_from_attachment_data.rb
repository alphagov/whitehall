class RemoveSynchronisedWithAssetManagerAtFromAttachmentData < ActiveRecord::Migration[5.1]
  def up
    # this condition is because the PR which added the column was
    # removed, so a freshly generated schema won't have it, causing
    # the migration to fail.  however, the column does exist in the
    # production database, so we want to remove it from there.
    if column_exists? :attachment_data, :synchronised_with_asset_manager_at
      remove_column :attachment_data, :synchronised_with_asset_manager_at
    end
  end
end

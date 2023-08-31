class AddUseNonLegacyEndpointsToAttachmentDataAndImageData < ActiveRecord::Migration[7.0]
  def change
    add_column :attachment_data, :use_non_legacy_endpoints, :boolean, null: false, default: false
    add_column :image_data, :use_non_legacy_endpoints, :boolean, null: false, default: false
  end
end

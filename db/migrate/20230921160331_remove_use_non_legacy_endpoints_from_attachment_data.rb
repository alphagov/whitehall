class RemoveUseNonLegacyEndpointsFromAttachmentData < ActiveRecord::Migration[7.0]
  def change
    remove_column :attachment_data, :use_non_legacy_endpoints, :boolean, if_exists: true
  end
end

class RemoveUseNonLegacyEndpointsFromImageData < ActiveRecord::Migration[7.0]
  def change
    remove_column :image_data, :use_non_legacy_endpoints, :boolean, if_exists: true
  end
end

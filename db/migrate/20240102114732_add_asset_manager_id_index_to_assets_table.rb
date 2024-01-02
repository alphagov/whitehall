class AddAssetManagerIdIndexToAssetsTable < ActiveRecord::Migration[7.1]
  def change
    add_index :assets, :asset_manager_id, if_not_exists: true
  end
end

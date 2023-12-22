class AddIndexToAssetManagerId < ActiveRecord::Migration[7.0]
  def change
    add_index :assets, :asset_manager_id
  end
end

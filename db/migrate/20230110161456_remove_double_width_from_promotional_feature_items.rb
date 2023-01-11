class RemoveDoubleWidthFromPromotionalFeatureItems < ActiveRecord::Migration[7.0]
  def change
    remove_column :promotional_feature_items, :double_width, :boolean, default: false
  end
end

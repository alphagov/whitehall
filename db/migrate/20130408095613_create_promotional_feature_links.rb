class CreatePromotionalFeatureLinks < ActiveRecord::Migration
  def change
    create_table :promotional_feature_links do |t|
      t.references :promotional_feature_item
      t.string :url
      t.string :text

      t.timestamps
    end

    add_index :promotional_feature_links, :promotional_feature_item_id
  end
end

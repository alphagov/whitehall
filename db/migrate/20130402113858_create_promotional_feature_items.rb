class CreatePromotionalFeatureItems < ActiveRecord::Migration
  def change
    create_table :promotional_feature_items do |t|
      t.references :promotional_feature
      t.text       :summary
      t.string     :image
      t.string     :image_alt_text
      t.string     :title
      t.string     :title_url
      t.boolean    :double_width, default: false
      t.timestamps
    end

    add_index :promotional_feature_items, :promotional_feature_id
  end
end

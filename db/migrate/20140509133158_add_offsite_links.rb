class AddOffsiteLinks < ActiveRecord::Migration
  def up
    create_table :offsite_links do |t|
      t.string   "title"
      t.string   "summary"
      t.string   "url"
      t.string   "link_type"
      t.integer  "parent_id"
      t.string   "parent_type"
      t.datetime "date"
      t.timestamps
    end
    add_column :features, :offsite_link_id, :integer
    add_index "features", %w[offsite_link_id], name: "index_features_on_offsite_link_id"
    add_column :classification_featurings, :offsite_link_id, :integer
    add_index "classification_featurings", %w[offsite_link_id], name: "index_classification_featurings_on_offsite_link_id"
  end

  def down
    drop_table :offsite_links
    remove_column :features, :offsite_link_id
    remove_column :classification_featurings, :offsite_link_id
  end
end

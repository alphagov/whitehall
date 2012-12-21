class CreateClassificationFeaturings < ActiveRecord::Migration
  def change
    create_table "classification_featuring_image_data" do |t|
      t.string   "carrierwave_image"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "classification_featurings" do |t|
      t.integer  "edition_id"
      t.integer  "classification_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "ordering"
      t.integer  "classification_featuring_image_data_id"
      t.string   "alt_text"
    end

    add_index "classification_featurings", ["edition_id", "classification_id"], name: "index_cl_feat_on_edition_id_and_classification_id", unique: true
    add_index "classification_featurings", ["classification_featuring_image_data_id"], name: "index_cl_feat_on_edition_org_image_data_id"
    add_index "classification_featurings", ["classification_id"], name: "index_cl_feat_on_classification_id"
  end
end

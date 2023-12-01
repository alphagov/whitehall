class DropDefaultNewsOrganisationImageData < ActiveRecord::Migration[7.0]
  def up
    drop_table :default_news_organisation_image_data
  end

  def down
    create_table "default_news_organisation_image_data", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
      t.string "carrierwave_image"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
    end
  end
end

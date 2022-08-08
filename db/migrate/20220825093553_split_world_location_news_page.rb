class SplitWorldLocationNewsPage < ActiveRecord::Migration[7.0]
  def up
    create_table :world_location_news do |t|
      t.integer "world_location_id"
      t.string "content_id"
      t.timestamps
    end

    execute "INSERT INTO
      world_location_news (id, world_location_id, content_id, created_at, updated_at)
      SELECT id, id, news_page_content_id, created_at, updated_at
      FROM world_locations"

    remove_column :world_locations, :news_page_content_id, :string

    create_table :world_location_news_translations do |t|
      t.integer "world_location_news_id"
      t.string "locale"
      t.string "title"
      t.text "mission_statement"
      t.timestamps
    end

    execute "INSERT INTO
      world_location_news_translations (world_location_news_id, locale, title, mission_statement, created_at, updated_at)
      SELECT world_location_id, locale, title, mission_statement, created_at, updated_at
      FROM world_location_translations"

    remove_column :world_location_translations, :title, :string # rubocop:disable Rails/BulkChangeTable
    remove_column :world_location_translations, :mission_statement, :text

    OffsiteLink.where(parent_type: "WorldLocation").update_all(parent_type: "WorldLocationNews")
    FeaturedLink.where(linkable_type: "WorldLocation").update_all(linkable_type: "WorldLocationNews")
    FeatureList.where(featurable_type: "WorldLocation").update_all(featurable_type: "WorldLocationNews")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

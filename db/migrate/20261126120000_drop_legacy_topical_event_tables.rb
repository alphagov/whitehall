class DropLegacyTopicalEventTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :topical_event_about_pages, id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci" do |t|
      t.integer "topical_event_id"
      t.string "name"
      t.text "summary", size: :medium
      t.text "body", size: :medium
      t.string "read_more_link_text"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "content_id"
    end

    drop_table :topical_event_featuring_image_data, id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci" do |t|
      t.string "carrierwave_image"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
    end

    drop_table :topical_event_featurings, id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci" do |t|
      t.integer "edition_id"
      t.integer "topical_event_id"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.integer "ordering"
      t.integer "topical_event_featuring_image_data_id"
      t.string "alt_text"
      t.integer "offsite_link_id"
      t.index %w[edition_id topical_event_id], name: "index_topical_event_feat_on_edition_id_and_topical_event_id", unique: true
      t.index %w[offsite_link_id], name: "index_topical_event_featurings_on_offsite_link_id"
      t.index %w[topical_event_featuring_image_data_id], name: "index_topical_event_feat_on_topical_event_feat_image_data_id"
      t.index %w[topical_event_id], name: "index_topical_event_feat_on_topical_event_id"
    end

    drop_table :topical_event_memberships, id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci" do |t|
      t.integer "topical_event_id"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.integer "edition_id"
      t.integer "ordering"
      t.index %w[edition_id], name: "index_topical_event_memberships_on_edition_id"
      t.index %w[topical_event_id], name: "index_topical_event_memberships_on_topical_event_id"
    end

    drop_table :topical_event_organisations, id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci" do |t|
      t.integer "organisation_id", null: false
      t.integer "topical_event_id", null: false
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.integer "ordering"
      t.boolean "lead", default: false, null: false
      t.integer "lead_ordering"
      t.index %w[organisation_id ordering], name: "index_topical_event_org_on_organisation_id_and_ordering", unique: true
      t.index %w[organisation_id], name: "index_topical_event_org_on_organisation_id"
      t.index %w[topical_event_id], name: "index_topical_event_org_on_topical_event_id"
    end

    drop_table :topical_events, id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci" do |t|
      t.string "name"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.text "description", size: :medium
      t.string "slug"
      t.string "state"
      t.string "logo_alt_text"
      t.date "start_date"
      t.date "end_date"
      t.string "content_id"
      t.text "summary", size: :medium
      t.index %w[slug], name: "index_topical_events_on_slug"
    end
  end
end

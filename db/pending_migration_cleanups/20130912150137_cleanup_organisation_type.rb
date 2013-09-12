class CleanupOrganisationType < ActiveRecord::Migration
  def up
    remove_index :organisations, :organisation_type_id
    remove_column :organisations, :organisation_type_id
    drop_table :organisation_types
  end

  def down
    create_table :organisation_types do |t|
      t.string :name
      t.string :analytics_prefix
      t.timestamps
    end
    execute %Q{
      INSERT INTO organisation_types
        (id, name, analytics_prefix, created_at, updated_at)
      VALUES
        (1,  "Ministerial department",                 "D", NOW(), NOW()),
        (2,  "Non-ministerial department",             "D", NOW(), NOW()),
        (3,  "Executive agency",                       "EA", NOW(), NOW()),
        (4,  "Executive non-departmental public body", "PB", NOW(), NOW()),
        (5,  "Advisory non-departmental public body",  "PB", NOW(), NOW()),
        (6,  "Tribunal non-departmental public body",  "PB", NOW(), NOW()),
        (7,  "Public corporation",                     "PC", NOW(), NOW()),
        (8,  "Independent monitoring body",            "IM", NOW(), NOW()),
        (9,  "Ad-hoc advisory group",                  "AG", NOW(), NOW()),
        (10, "Other",                                  "OT", NOW(), NOW()),
        (11, "Sub-organisation",                       "OT", NOW(), NOW()),
        (12, "Executive office",                       "EO", NOW(), NOW())
    }

    add_column :organisations, :organisation_type_id, :int
    add_index :organisations, :organisation_type_id
  end
end

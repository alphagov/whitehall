class AddDataMigrationForOffsiteLinkParents < ActiveRecord::Migration[8.0]
  # We chose to use an active record migration here instead of a data migration
  # so it runs immediately as pods come up, eliminating the gap where new offsite links could be created in the old shape.
  # Running both together keeps the window for inconsistent data essentially zero.
  def up
    safety_assured do
      execute <<-SQL
        INSERT INTO offsite_link_parents (offsite_link_id, parent_id, parent_type, created_at, updated_at)
        SELECT id, parent_id, parent_type, NOW(), NOW()
        FROM offsite_links AS ol
        WHERE NOT EXISTS (
            SELECT 1
            FROM offsite_link_parents AS olp
            WHERE olp.offsite_link_id = ol.id
          );
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

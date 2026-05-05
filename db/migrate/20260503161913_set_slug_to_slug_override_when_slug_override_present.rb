class SetSlugToSlugOverrideWhenSlugOverridePresent < ActiveRecord::Migration[8.1]
  def change
    find_slug_overrides_sql = <<-SQL
      SELECT e.id
      FROM editions e
      WHERE e.slug_override IS NOT NULL
      AND e.slug_override != ''
      AND e.slug != e.slug_override
      AND e.state NOT IN ('deleted', 'superseded');
    SQL

    edition_ids = ActiveRecord::Base.connection.select_values(find_slug_overrides_sql)
    Rails.logger.info "Found #{edition_ids.size} editions where the slug does not match the slug_override."

    update_sql = <<-SQL
      UPDATE editions e
      SET e.slug = e.slug_override
      WHERE e.slug_override IS NOT NULL
      AND e.slug_override != ''
      AND e.slug != e.slug_override
      AND e.state NOT IN ('deleted', 'superseded');
    SQL

    updated_editions = ActiveRecord::Base.connection.update(update_sql)
    Rails.logger.info "\nMigration complete. Slug set to the value of the slug_override for #{updated_editions} editions."
  end
end

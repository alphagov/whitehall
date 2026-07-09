class ReplaceTwitterWithXOnTopicalEvents < ActiveRecord::Migration[8.1]
  def change
    update_social_media_links_sql = <<-SQL
      UPDATE edition_translations et
      JOIN editions e
        ON et.edition_id = e.id
      SET et.block_content = JSON_REPLACE(
        et.block_content,
        JSON_UNQUOTE(JSON_SEARCH(et.block_content, 'one', 'Twitter', NULL, '$.social_media_links[*].social_media_service_name')),
        'X'
      )
      WHERE e.configurable_document_type = 'topical_event'
        AND JSON_CONTAINS_PATH(et.block_content, 'one', '$.social_media_links')
        AND JSON_SEARCH(et.block_content, 'one', 'Twitter') IS NOT NULL
    SQL

    updated_editions = ActiveRecord::Base.connection.update(update_social_media_links_sql)
    Rails.logger.info "\nMigration completed. Social media link updated to X for #{updated_editions} editions."
  end
end

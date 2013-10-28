class AddHtmlColumnsToAttachments < ActiveRecord::Migration
  def up
    add_column :attachments, :type, :string
    add_column :attachments, :slug, :string
    add_column :attachments, :body, :text, limit: 4.gigabytes - 1
    add_column :attachments, :manually_numbered_headings, :boolean

    transaction do
      execute "UPDATE attachments SET type = 'FileAttachment' WHERE type IS NULL"

      execute %Q{
        INSERT INTO attachments
          (`type`, attachable_id, attachable_type, title, body, slug, manually_numbered_headings, ordering, created_at, updated_at)
        SELECT 'HtmlAttachment', edition_id, 'Edition', title, body, slug, manually_numbered, -1, created_at, updated_at
        FROM html_versions
        WHERE edition_id IS NOT NULL
        AND title IS NOT NULL
        AND title != ''
        AND body IS NOT NULL
        AND body != '';
      }
    end
  end

  def down
    remove_column :attachments, :type
    remove_column :attachments, :slug
    remove_column :attachments, :body
    remove_column :attachments, :manually_numbered_headings
  end
end

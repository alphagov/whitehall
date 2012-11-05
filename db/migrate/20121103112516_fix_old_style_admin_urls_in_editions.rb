class FixOldStyleAdminUrlsInEditions < ActiveRecord::Migration
  def up
    old_path, new_path = "/government/admin/documents", "/government/admin/editions"
    update %{ UPDATE editions SET summary = REPLACE(summary, '#{old_path}', '#{new_path}') }
    update %{ UPDATE editions SET body = REPLACE(body, '#{old_path}', '#{new_path}') }
    update %{ UPDATE supporting_pages SET body = REPLACE(body, '#{old_path}', '#{new_path}') }
  end

  def down
    # intentionally left blank
  end
end

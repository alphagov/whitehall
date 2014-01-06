class DropHtmlVersions < ActiveRecord::Migration
  def up
    drop_table :html_versions
  end

  def down
    raise ActiveRecore::IrreversibleMigration
  end
end

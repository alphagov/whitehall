class AddImportEnqueuedAtToImport < ActiveRecord::Migration
  def change
    add_column :imports, :import_enqueued_at, :datetime
    execute "update imports set import_enqueued_at=import_started_at"
  end
end

class DeleteImportRelatedTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :import_errors
    drop_table :import_logs
    drop_table :imports
  end
end

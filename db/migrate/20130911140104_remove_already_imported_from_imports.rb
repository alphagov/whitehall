class RemoveAlreadyImportedFromImports < ActiveRecord::Migration
  def up
    remove_column :imports, :already_imported
  end

  def down
    add_column :imports, :already_imported, :text
  end
end

class ChangeImportErrorMessageColumnTypeToText < ActiveRecord::Migration
  def up
    change_column :import_errors, :message, :text
  end
end

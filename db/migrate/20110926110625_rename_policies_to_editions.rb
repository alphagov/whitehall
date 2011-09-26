class RenamePoliciesToEditions < ActiveRecord::Migration
  def change
    rename_table :policies, :editions
  end
end
class AddDepartmentalEditorFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :departmental_editor, :boolean, default: false
  end
end
class AddVisualEditorToEditions < ActiveRecord::Migration[7.1]
  def change
    add_column :editions, :visual_editor, :boolean
  end
end

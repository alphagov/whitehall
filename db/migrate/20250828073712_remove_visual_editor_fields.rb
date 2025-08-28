class RemoveVisualEditorFields < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      remove_column :editions, :visual_editor, :boolean
      remove_column :attachments, :visual_editor, :boolean
    end
  end

  def down
    add_column :editions, :visual_editor, :boolean
    add_column :attachments, :visual_editor, :boolean
  end
end

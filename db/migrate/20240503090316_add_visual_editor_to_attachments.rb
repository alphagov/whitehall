class AddVisualEditorToAttachments < ActiveRecord::Migration[7.1]
  def change
    add_column :attachments, :visual_editor, :boolean
  end
end

class ChangeObjectNameColumnToObjectTitle < ActiveRecord::Migration[8.0]
  def up
    rename_column :content_block_versions, :updated_embedded_object_name, :updated_embedded_object_title
  end

  def down
    rename_column :content_block_versions, :updated_embedded_object_title, :updated_embedded_object_name
  end
end

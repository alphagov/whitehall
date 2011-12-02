class RenameEditorialGuidance < ActiveRecord::Migration
  def change
    rename_column :documents, :editorial_guidance, :notes_to_editors
  end
end
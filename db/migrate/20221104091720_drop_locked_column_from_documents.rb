class DropLockedColumnFromDocuments < ActiveRecord::Migration[7.0]
  def change
    remove_column :documents, :locked, :boolean, default: false, null: false
  end
end

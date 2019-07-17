class AddLockedFlagToDocument < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :locked, :boolean, default: false, null: false
  end
end

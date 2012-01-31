class AddChangeNoteToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :change_note, :text
  end
end
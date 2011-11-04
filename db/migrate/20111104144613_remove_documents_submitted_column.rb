class RemoveDocumentsSubmittedColumn < ActiveRecord::Migration
  def change
    remove_column :documents, :submitted
  end
end

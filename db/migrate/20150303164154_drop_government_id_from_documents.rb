class DropGovernmentIdFromDocuments < ActiveRecord::Migration
  def change
    remove_column :documents, :government_id
  end
end

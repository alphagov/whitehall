class AddStubFlagToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :stub, :boolean, default: false
  end
end
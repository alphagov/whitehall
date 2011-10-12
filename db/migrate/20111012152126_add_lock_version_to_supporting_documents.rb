class AddLockVersionToSupportingDocuments < ActiveRecord::Migration
  def change
    add_column :supporting_documents, :lock_version, :integer, default: 0
  end
end
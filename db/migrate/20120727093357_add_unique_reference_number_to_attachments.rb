class AddUniqueReferenceNumberToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :unique_reference, :string
  end
end
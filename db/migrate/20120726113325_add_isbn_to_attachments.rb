class AddIsbnToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :isbn, :string
  end
end
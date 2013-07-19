class AddOrderingToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :ordering, :integer
    add_index :attachments, :ordering
  end
end

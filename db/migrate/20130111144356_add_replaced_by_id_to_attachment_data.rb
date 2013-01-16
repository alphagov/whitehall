class AddReplacedByIdToAttachmentData < ActiveRecord::Migration
  def change
    add_column :attachment_data, :replaced_by_id, :integer
    add_index :attachment_data, :replaced_by_id
  end
end

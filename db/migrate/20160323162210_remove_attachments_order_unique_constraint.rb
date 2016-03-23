class RemoveAttachmentsOrderUniqueConstraint < ActiveRecord::Migration
  def change
    remove_index :attachments, name: "no_duplicate_attachment_orderings"
  end
end

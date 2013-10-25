class PreventDuplicateAttachmentOrderings < ActiveRecord::Migration
  def change
    change_column :attachments, :ordering, :integer, :null => false
    add_index :attachments, [:attachable_type, :attachable_id, :ordering], unique: :true, name: "no_duplicate_attachment_orderings"
  end
end

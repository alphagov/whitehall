class AddSafelyResluggableToAttachment < ActiveRecord::Migration[5.1]
  def change
    add_column :attachments, :safely_resluggable, :boolean, default: true
    Attachment.update_all(safely_resluggable: false)
  end
end

class AddPresentOnUnpublishToAttachmentData < ActiveRecord::Migration[5.0]
  def change
    add_column :attachment_data, :present_at_unpublish, :boolean
    AttachmentData.reset_column_information
  end
end

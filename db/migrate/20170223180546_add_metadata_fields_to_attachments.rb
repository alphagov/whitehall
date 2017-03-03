class AddMetadataFieldsToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :print_meta_data_contact_address, :string
  end
end

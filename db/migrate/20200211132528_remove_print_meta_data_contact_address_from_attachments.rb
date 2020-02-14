class RemovePrintMetaDataContactAddressFromAttachments < ActiveRecord::Migration[5.1]
  def change
    remove_column :attachments, :print_meta_data_contact_address, :string
  end
end

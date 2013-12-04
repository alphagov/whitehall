class AddLocaleToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :locale, :string
  end
end

class AddExternalUrlToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :external_url, :string
  end
end

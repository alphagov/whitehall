class AddWebIsbnToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :web_isbn, :string
  end
end

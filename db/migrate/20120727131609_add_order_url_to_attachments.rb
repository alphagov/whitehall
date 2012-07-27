class AddOrderUrlToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :order_url, :string
  end
end
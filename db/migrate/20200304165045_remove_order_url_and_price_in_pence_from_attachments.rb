class RemoveOrderUrlAndPriceInPenceFromAttachments < ActiveRecord::Migration[5.1]
  def change
    remove_column :attachments, :order_url, :string
    remove_column :attachments, :price_in_pence, :integer
  end
end

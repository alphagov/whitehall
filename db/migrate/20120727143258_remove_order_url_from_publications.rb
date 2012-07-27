class RemoveOrderUrlFromPublications < ActiveRecord::Migration
  def up
    remove_column :editions, :order_url
  end

  def down
    add_column :editions, :order_url, :string
  end
end

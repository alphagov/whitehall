class AddPriceToPublications < ActiveRecord::Migration
  def change
    add_column :editions, :price_in_pence, :integer
  end
end
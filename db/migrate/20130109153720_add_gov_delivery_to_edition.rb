class AddGovDeliveryToEdition < ActiveRecord::Migration
  def change
    add_column :editions, :govdelivery_url, :text
  end
end

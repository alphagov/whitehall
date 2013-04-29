class RemoveGovDeliveryUrl < ActiveRecord::Migration
  def change
    remove_column :classifications, :govdelivery_url
    remove_column :editions, :govdelivery_url
    remove_column :organisations, :govdelivery_url
  end
end

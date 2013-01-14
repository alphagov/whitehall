class AddGovdeliveryUrlToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :govdelivery_url, :text
  end
end

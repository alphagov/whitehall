class AddGovdeliveryUrlToClassifications < ActiveRecord::Migration
  def change
    add_column :classifications, :govdelivery_url, :text
  end
end

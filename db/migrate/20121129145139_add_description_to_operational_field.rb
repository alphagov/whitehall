class AddDescriptionToOperationalField < ActiveRecord::Migration
  def change
    add_column :operational_fields, :description, :text
  end
end

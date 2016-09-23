class AddContentIdToOperationalField < ActiveRecord::Migration
  def change
    add_column :operational_fields, :content_id, :string
  end
end

class AddContentIdToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :content_id, :string, null: false
    add_index :organisations, :content_id, :unique => true
  end
end

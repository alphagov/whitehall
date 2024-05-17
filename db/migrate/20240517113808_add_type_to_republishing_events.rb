class AddTypeToRepublishingEvents < ActiveRecord::Migration[7.1]
  def change
    change_table :republishing_events, bulk: true do |t|
      t.boolean :bulk, null: false
      t.integer :bulk_content_type
      t.string :content_id
    end
  end
end

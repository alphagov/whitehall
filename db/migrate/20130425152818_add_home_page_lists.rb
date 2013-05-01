class AddHomePageLists < ActiveRecord::Migration
  def change
    create_table :home_page_lists do |t|
      t.references :owner, polymorphic: true, null: false
      t.string :name
      t.timestamps
    end
    add_index :home_page_lists, [:owner_id, :owner_type, :name], unique: true

    create_table :home_page_list_items do |t|
      t.references :home_page_list, null: false
      t.references :item, polymorphic: true, null: false
      t.integer :ordering
      t.timestamps
    end
    add_index :home_page_list_items, [:home_page_list_id]
    add_index :home_page_list_items, [:item_id, :item_type]
    add_index :home_page_list_items, [:home_page_list_id, :ordering]
  end
end

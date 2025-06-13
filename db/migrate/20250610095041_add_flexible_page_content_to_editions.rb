class AddFlexiblePageContentToEditions < ActiveRecord::Migration[8.0]
  def change
    change_table :editions, bulk: true do |t|
      t.string :flexible_page_type, default: nil
      t.index :flexible_page_type
    end
    add_column :edition_translations, :flexible_page_content, :json, default: nil
  end
end

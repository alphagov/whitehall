class AddFlexiblePageContentToEditions < ActiveRecord::Migration[8.0]
  def change
    change_table :editions, bulk: true do |t|
      t.string :flexible_page_type, default: nil
      t.json :flexible_page_content, default: nil
      t.index :flexible_page_type
    end
  end
end

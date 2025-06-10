class AddFlexiblePageContentToEditions < ActiveRecord::Migration[8.0]
  def change
    add_column :editions, :flexible_page_content, :json, default: nil
  end
end

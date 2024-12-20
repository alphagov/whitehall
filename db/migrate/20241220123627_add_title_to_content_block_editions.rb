class AddTitleToContentBlockEditions < ActiveRecord::Migration[7.1]
  def up
    change_table :content_block_editions, bulk: true do |t|
      t.string "title", default: "", null: false
    end
  end

  def down
    change_table :content_block_editions, bulk: true do |t|
      t.remove :title
    end
  end
end

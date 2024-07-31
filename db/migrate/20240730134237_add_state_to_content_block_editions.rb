class AddStateToContentBlockEditions < ActiveRecord::Migration[7.1]
  def up
    change_table :content_block_editions, bulk: true do |t|
      t.string "state", default: "draft", null: false
    end
  end

  def down
    change_table :content_block_editions, bulk: true do |t|
      t.remove :state
    end
  end
end

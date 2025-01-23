class AddChangeNoteAndMajorChangeToContentBlockEditions < ActiveRecord::Migration[7.1]
  def up
    change_table :content_block_editions, bulk: true do |t|
      t.string "change_note"
      t.boolean "major_change"
    end
  end

  def down
    change_table :content_block_editions, bulk: true do |t|
      t.remove "change_note"
      t.remove "major_change"
    end
  end
end

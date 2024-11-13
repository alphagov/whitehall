class AddInstructionsToPublishersToContentBlockEditions < ActiveRecord::Migration[7.1]
  def up
    change_table :content_block_editions, bulk: true do |t|
      t.text "instructions_to_publishers"
    end
  end

  def down
    change_table :content_block_editions, bulk: true do |t|
      t.remove :instructions_to_publishers
    end
  end
end

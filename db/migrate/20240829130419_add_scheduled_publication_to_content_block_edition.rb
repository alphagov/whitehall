class AddScheduledPublicationToContentBlockEdition < ActiveRecord::Migration[7.1]
  def up
    change_table :content_block_editions, bulk: true do |t|
      t.datetime "scheduled_publication", precision: nil
    end
  end

  def down
    change_table :content_block_editions, bulk: true do |t|
      t.remove :scheduled_publication
    end
  end
end

class AddStateToContentBlockVersions < ActiveRecord::Migration[7.1]
  def up
    change_table :content_block_versions, bulk: true do |t|
      t.text "state"
    end
  end

  def down
    change_table :content_block_versions, bulk: true do |t|
      t.remove :state
    end
  end
end

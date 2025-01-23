class AddFieldDiffsToContentBlockVersions < ActiveRecord::Migration[7.1]
  def up
    change_table :content_block_versions, bulk: true do |t|
      t.json "field_diffs"
    end
  end

  def down
    change_table :content_block_versions, bulk: true do |t|
      t.remove :field_diffs
    end
  end
end

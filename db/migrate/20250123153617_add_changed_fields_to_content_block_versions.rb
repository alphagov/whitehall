class AddChangedFieldsToContentBlockVersions < ActiveRecord::Migration[7.1]
  def up
    change_table :content_block_versions, bulk: true do |t|
      t.json "changed_fields"
    end
  end

  def down
    change_table :content_block_versions, bulk: true do |t|
      t.remove :changed_fields
    end
  end
end

class AddEventDetailsToVersions < ActiveRecord::Migration[8.0]
  def up
    change_table :content_block_versions, bulk: true do |t|
      t.string :updated_embedded_object_type
      t.string :updated_embedded_object_name
    end
  end

  def down
    change_table :content_block_versions, bulk: true do |t|
      t.remove :updated_embedded_object_type
      t.remove :updated_embedded_object_name
    end
  end
end

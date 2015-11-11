require "securerandom"

class AddContentIdToUnpublishing < ActiveRecord::Migration
  def up
    add_column :unpublishings, :content_id, :string
    Unpublishing.find_each do |unpublishing|
      unpublishing.update_columns(content_id: SecureRandom.uuid)
    end
    change_column_null :unpublishings, :content_id, false
  end

  def down
    remove_column :unpublishings, :content_id
  end
end

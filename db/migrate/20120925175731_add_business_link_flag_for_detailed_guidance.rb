class AddBusinessLinkFlagForDetailedGuidance < ActiveRecord::Migration
  def up
    add_column :editions, :replaces_businesslink, :boolean, default: false
    update("UPDATE editions SET replaces_businesslink = 1")
  end

  def down
    remove_column :editions, :replaces_businesslink
  end
end

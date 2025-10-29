class RemoveReplacesBusinesslinkFromEditions < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      remove_column :editions, :replaces_businesslink, :boolean
    end
  end

  def down
    add_column :editions, :replaces_businesslink, :boolean, default: false
  end
end
